#!/usr/bin/env bash
# test — run tests per ecosystem + Bash unit tests (bats). Tolerant: skips what is not present.
set -euo pipefail
cd "$(dirname "$0")/.."

note() { printf '\033[1m==>\033[0m %s\n' "$1"; }

[[ -f frontend/package.json ]] && { note "frontend tests"; npm --prefix frontend test --if-present; } || note "frontend: skip"
[[ -f backend/pyproject.toml ]] && { note "backend tests"; ( cd backend && uv run pytest -q ); } || note "backend: skip"

if command -v bats >/dev/null 2>&1 && compgen -G "scripts/tests/*.bats" >/dev/null; then
  note "bash (bats) tests"; bats scripts/tests
else
  note "bats: skip (not installed or no scripts/tests/*.bats)"
fi
