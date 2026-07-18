#!/usr/bin/env bash
# doctor — preflight check for the dev environment (focus macOS 26.5.1).
# Verifies required tooling and access (GitHub SSH, Anthropic OAuth or API key).
# Functions are kept small and side-effect-free so they can be unit-tested with bats.
# Exit status: 0 if all REQUIRED checks pass, 1 otherwise (warnings never fail).
set -uo pipefail

# --- output helpers ---------------------------------------------------------
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
fail() { printf '  \033[31m✗\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m⚠\033[0m %s\n' "$1"; }
section() { printf '\n\033[1m%s\033[0m\n' "$1"; }

# --- pure-ish checks (return 0/1, print nothing) ----------------------------
has_cmd()        { command -v "$1" >/dev/null 2>&1; }
github_ssh_ok()  {
  # Prefer the real transport test when a GitHub origin is configured; fall back to `ssh -T`.
  if git remote get-url origin 2>/dev/null | grep -q 'github\.com'; then
    git ls-remote --heads origin >/dev/null 2>&1 && return 0
  fi
  ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | grep -q "successfully authenticated"
}
anthropic_ok()   { [[ -n "${ANTHROPIC_API_KEY:-}" ]] || [[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]] || has_cmd claude; }
# Logged into Infisical (the secrets source of truth)? `</dev/null` stops the CLI from launching its
# interactive login flow when no session exists, so the check fails fast instead of hanging.
infisical_auth_ok() { has_cmd infisical && infisical user get token --silent </dev/null >/dev/null 2>&1; }

# --- reporting --------------------------------------------------------------
RC=0
check_required() { if has_cmd "$1"; then ok "$1 ($(${1} --version 2>&1 | head -1))"; else fail "$1 (REQUIRED — install it)"; RC=1; fi; }
check_optional() { if has_cmd "$1"; then ok "$1"; else warn "$1 (optional — $2)"; fi; }

main() {
  section "Tools (required, global)"
  for t in git node npm uv gh direnv; do check_required "$t"; done

  section "Tools (recommended, global via Homebrew)"
  check_optional git-cliff "brew install git-cliff — local CHANGELOG generation"
  check_optional gitleaks  "brew install gitleaks — secret scanning (pre-commit hook + CI)"
  check_optional bats      "brew install bats-core — Bash unit tests"
  check_optional openspec  "brew install openspec — spec-driven workflow"
  check_optional tenv      "brew install tenv — Terraform/OpenTofu (later lots)"
  check_optional infisical "brew install infisical/get-cli/infisical — secrets source of truth"

  printf '\n\033[1m%s\033[0m\n  %s\n' "Project dev tools (installed by 'make init', not global)" \
    "pre-commit → uv dev dep (each ecosystem); wrangler → npm devDependency (frontend)"

  section "Access"
  if github_ssh_ok; then ok "GitHub SSH authenticated"; else fail "GitHub SSH (REQUIRED — add your SSH key to GitHub)"; RC=1; fi
  if anthropic_ok; then ok "Anthropic auth available (OAuth session or ANTHROPIC_API_KEY)"; else fail "Anthropic auth (REQUIRED — login via OAuth or set ANTHROPIC_API_KEY in .env)"; RC=1; fi
  if infisical_auth_ok; then ok "Infisical authenticated (secrets source of truth)"; else warn "Infisical not authenticated (needed for secrets — 'infisical login' + 'infisical init', then 'make secrets-pull')"; fi

  section "Result"
  if [[ $RC -eq 0 ]]; then ok "Environment is ready."; else fail "Some required checks failed — see above."; fi
  return $RC
}

# Only run when executed directly (sourcing exposes functions for bats).
if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
  main "$@"
fi
