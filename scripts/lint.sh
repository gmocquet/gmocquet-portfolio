#!/usr/bin/env bash
# lint — auto-format + lint + pre-commit checks, per ecosystem.
# One entry point (run by `make lint`, the git pre-commit hook, and CI) applying each ecosystem's
# .pre-commit-config.yaml explicitly. Pass --staged to limit to staged files (used by the git hook).
set -euo pipefail
cd "$(dirname "$0")/.."

STAGED=0
[[ "${1:-}" == "--staged" ]] && STAGED=1

note() { printf '\033[1m==>\033[0m %s\n' "$1"; }

run_ecosystem() {
  local dir="$1" cfg="$1/.pre-commit-config.yaml"
  [[ -f "$cfg" ]] || { note "$dir: no .pre-commit-config.yaml — skipping"; return 0; }
  command -v pre-commit >/dev/null 2>&1 || { note "pre-commit not installed — run 'make doctor'"; return 0; }
  note "$dir: pre-commit"
  if [[ $STAGED -eq 1 ]]; then
    local files
    files=$(git diff --cached --name-only --diff-filter=ACMR -- "$dir" || true)
    [[ -z "$files" ]] && return 0
    pre-commit run --config "$cfg" --files $files
  else
    pre-commit run --config "$cfg" --all-files
  fi
}

run_ecosystem frontend
run_ecosystem backend
