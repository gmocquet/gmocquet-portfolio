#!/usr/bin/env bash
# changelog — regenerate CHANGELOG.md from Conventional Commits, enriched with each change's PR number
# and author via the GitHub API (git-cliff [remote.github]). Enrichment REQUIRES the repo's
# fine-grained PAT GH_PAT_TOKEN — the same one that pushes release tags (ADR 0010) — with
# **Pull requests: Read** in addition to Contents. There is intentionally NO offline fallback: without
# a working token the changelog would silently drop PR/author data, so we fail loudly with the exact
# fix. The PAT is scripted end to end: `make repo-settings-token-{set,status,delete}`.
#
# Usage: changelog.sh [TAG]   (TAG=vX.Y.Z labels the unreleased commits as that upcoming release)
set -euo pipefail
cd "$(dirname "$0")/.."

tag="${1:-}"

command -v gh >/dev/null 2>&1 || { echo "gh is required (brew install gh)" >&2; exit 1; }

if [ -z "${GH_PAT_TOKEN:-}" ]; then
  cat >&2 <<'MSG'
ERROR: GH_PAT_TOKEN is not set — the changelog reads PR/author data from the GitHub API and needs it.
It is the same fine-grained PAT that pushes release tags: Contents (read/write) + Pull requests (read).
  create/store it:  make repo-settings-token-set
  check it:         GH_PAT_TOKEN=<token> make repo-settings-token-status
  then:             GH_PAT_TOKEN=<token> make changelog
MSG
  exit 1
fi

repo="${GITHUB_REPOSITORY:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
if ! GH_TOKEN="$GH_PAT_TOKEN" gh api "repos/${repo}/pulls?per_page=1&state=closed" >/dev/null 2>&1; then
  echo "ERROR: GH_PAT_TOKEN cannot read pull requests on ${repo} — add 'Pull requests: Read' to the PAT," >&2
  echo "       then re-store it: make repo-settings-token-set (the pre-filled page now requests it)." >&2
  exit 1
fi

git cliff ${tag:+--tag "$tag"} --github-token "$GH_PAT_TOKEN" --output CHANGELOG.md
