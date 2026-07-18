#!/usr/bin/env bash
# secret-scan — repo-wide secret scanning with gitleaks (defense-in-depth, works while private).
# One entry point (run by `make secret-scan`, the git pre-commit hook, and CI), two modes:
#   (default)  scan the FULL git history (all refs) — used by CI and `make secret-scan`.
#   --staged   scan only staged changes — used by the pre-commit hook to block a leak before commit.
# GitHub's native secret scanning is free only on PUBLIC repos; this covers us while the repo stays
# private, and remains a second layer once it is public. See docs/adrs/0011-secret-scanning-defense-in-depth.md.
# Functions are kept small and side-effect-free so they can be unit-tested with bats.
set -euo pipefail
cd "$(dirname "$0")/.."

note() { printf '\033[1m==>\033[0m %s\n' "$1"; }

# Build the gitleaks argument list for a mode. Pure: prints the args (one per line), touches nothing.
#   staged -> scan staged changes (pre-commit);  full -> scan the whole history (every ref).
gitleaks_args() {
  local mode="$1"
  if [[ "$mode" == "staged" ]]; then
    printf '%s\n' git --staged --redact --no-banner --verbose .
  else
    printf '%s\n' git --log-opts=--all --redact --no-banner --verbose .
  fi
}

main() {
  local mode="full"
  [[ "${1:-}" == "--staged" ]] && mode="staged"

  # A missing dev tool must not block a commit: skip locally (CI runs the same scan on a pinned
  # gitleaks, so a leak is still caught before it can land on main).
  if ! command -v gitleaks >/dev/null 2>&1; then
    note "gitleaks not found — install it (brew install gitleaks). Skipping local secret scan."
    return 0
  fi

  note "secret scan (gitleaks, mode=$mode)"
  # shellcheck disable=SC2046 # gitleaks_args prints one token per line; word-splitting is intended.
  gitleaks $(gitleaks_args "$mode")
}

# Only run when executed directly (sourcing exposes functions for bats).
if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
  main "$@"
fi
