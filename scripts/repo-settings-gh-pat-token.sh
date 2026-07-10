#!/usr/bin/env bash
# repo-settings-gh-pat-token — provision & manage the fine-grained GitHub PAT that lets CI create the
# `v*` release tags which trigger downstream workflows. The automatic GITHUB_TOKEN cannot start new
# workflow runs (GitHub anti-recursion; only workflow_dispatch/repository_dispatch are exempt), so
# .github/workflows/release-tag.yml pushes the tag with this PAT — a push from a real user identity,
# which fires deploy.yml. See ADR 0010.
#
# The PAT is stored as a GitHub Actions secret (GH_PAT_TOKEN) — a documented exception to the
# Infisical source-of-truth (ADR 0009): it is a GitHub-native bootstrap credential, used only inside
# Actions to authenticate a git tag push, and there is no OIDC path to push tags as a user.
#
# Requires an authenticated `gh` CLI with admin on the repo. Idempotent: safe to re-run.
# Usage: repo-settings-gh-pat-token.sh <set|status|delete>
# Logic is isolated (pure functions + a sourcing guard) so bats can unit-test it.
set -euo pipefail

: "${SECRET_NAME:=GH_PAT_TOKEN}"
: "${PAT_EXPIRES_IN:=none}"        # GitHub PAT `expires_in`: "none" (No expiration) or a number of days.

# urlencode <string> — percent-encode a value for use in a query string (ASCII input).
urlencode() {
  local s="$1" i c out=""
  for ((i = 0; i < ${#s}; i++)); do
    c="${s:i:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) out+="$c" ;;
      *) printf -v c '%%%02X' "'$c"; out+="$c" ;;
    esac
  done
  printf '%s' "$out"
}

# pat_url <owner> <repo_name> — echo the pre-filled fine-grained PAT creation URL (Contents: Read and
# write on this repo owner). GitHub exposes no query param to pre-select the repository, so the user
# still picks it in the form.
pat_url() {
  local owner="$1" repo_name="$2" name desc
  name="${repo_name}-gh-pat-token"
  desc="CI token for ${repo_name}. Used by the release-tag GitHub Actions workflow to push v* release tags so the deploy workflow triggers (the automatic GITHUB_TOKEN cannot trigger downstream workflows). Scope: Contents read and write on ${repo_name} only."
  printf 'https://github.com/settings/personal-access-tokens/new?name=%s&description=%s&target_name=%s&expires_in=%s&contents=write\n' \
    "$(urlencode "$name")" "$(urlencode "$desc")" "$owner" "$PAT_EXPIRES_IN"
}

# open_url <url> — open in the default browser, or print it when no opener is available.
open_url() {
  if command -v open >/dev/null 2>&1; then open "$1"
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$1"
  else echo "Open this URL: $1"; fi
}

# cmd_set <owner> <repo> — guide the PAT creation, then store the pasted token as the Actions secret.
cmd_set() {
  local owner="$1" repo="$2" name="${2##*/}"
  echo "==> $SECRET_NAME — fine-grained PAT so CI can push v* release tags that trigger deploy."
  echo "    Scope: Contents read/write on $repo only. Stored as a GitHub Actions secret."
  echo ""
  echo "Opening the pre-filled PAT page (name, description, expiry and Contents: Read and write are"
  echo "set). GitHub cannot pre-select the repository, so you still need to:"
  echo "  - set Repository access -> Only select repositories -> $repo"
  echo "  - click Generate token, then copy it."
  echo ""
  open_url "$(pat_url "$owner" "$name")"
  printf "Press Enter once the token is generated and copied... "; read -r _
  echo "Paste the token when prompted:"
  gh secret set "$SECRET_NAME" --repo "$repo"
  echo ""
  echo "==> stored $SECRET_NAME on $repo. Verify with: make repo-settings-gh-pat-token-status"
}

# cmd_status <repo> — report whether the Actions secret exists.
cmd_status() {
  local repo="$1"
  if gh secret list --repo "$repo" | grep -q "^${SECRET_NAME}[[:space:]]"; then
    echo "$SECRET_NAME: set on $repo"
  else
    echo "$SECRET_NAME: not set on $repo"
  fi
}

# cmd_delete <repo> — remove the Actions secret.
cmd_delete() {
  local repo="$1"
  gh secret delete "$SECRET_NAME" --repo "$repo"
  echo "==> deleted $SECRET_NAME from $repo"
}

usage() { echo "usage: $(basename "$0") <set|status|delete>" >&2; }

main() {
  command -v gh >/dev/null 2>&1 || { echo "gh is required (brew install gh && gh auth login)" >&2; exit 1; }
  local repo owner
  repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
  owner=${repo%/*}
  case "${1:-}" in
    set)    cmd_set "$owner" "$repo" ;;
    status) cmd_status "$repo" ;;
    delete) cmd_delete "$repo" ;;
    *)      usage; exit 1 ;;
  esac
}

# Only run when executed directly (sourcing exposes the functions for bats).
if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
  main "$@"
fi
