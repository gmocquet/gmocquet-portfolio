#!/usr/bin/env bash
# init — install dependencies and the pre-commit git hook for each ecosystem that exists.
# Tolerant by design: skips an ecosystem (with a notice) when it is not scaffolded yet.
set -euo pipefail
cd "$(dirname "$0")/.."

note() { printf '\033[1m==>\033[0m %s\n' "$1"; }

if [[ -f frontend/package.json ]]; then
  note "frontend: installing npm dependencies"
  if [[ -f frontend/package-lock.json ]]; then npm --prefix frontend ci; else npm --prefix frontend install; fi
else
  note "frontend: not scaffolded yet — skipping"
fi

if [[ -f backend/pyproject.toml ]]; then
  note "backend: syncing uv environment"
  ( cd backend && uv sync )
else
  note "backend: not scaffolded yet — skipping"
fi

# Single git hook delegating to scripts/lint.sh, which applies each ecosystem's
# .pre-commit-config.yaml explicitly (one config per ecosystem, one entry point).
note "installing pre-commit git hook -> scripts/lint.sh"
hook=".git/hooks/pre-commit"
printf '#!/usr/bin/env bash\nexec "$(git rev-parse --show-toplevel)/scripts/lint.sh" --staged\n' > "$hook"
chmod +x "$hook"

# Client-side PR-only guard: block direct pushes to main (server-side protection needs a public
# repo or GitHub Pro). Bypass intentionally with `git push --no-verify` if ever required.
note "installing pre-push git hook -> block direct pushes to main"
pp=".git/hooks/pre-push"
cat > "$pp" <<'HOOK'
#!/usr/bin/env bash
while read -r _ _ remote_ref _; do
  if [[ "$remote_ref" == "refs/heads/main" ]]; then
    echo "✗ Direct pushes to 'main' are blocked (PR-only). Open a PR instead (or use --no-verify)." >&2
    exit 1
  fi
done
HOOK
chmod +x "$pp"

note "init done."
