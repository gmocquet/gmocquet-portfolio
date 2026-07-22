#!/usr/bin/env bash
# github-bootstrap — reproducible GitHub governance (no ClickOps).
# Idempotent: safe to re-run. Requires an authenticated `gh` CLI (SSH protocol).
# Creates: labels, milestones M0..M6, a Project (v2) board, and branch protection on main.
set -euo pipefail

command -v gh >/dev/null 2>&1 || { echo "gh is required (brew install gh && gh auth login)"; exit 1; }
gh config set git_protocol ssh >/dev/null 2>&1 || true

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
OWNER=${REPO%/*}
echo "==> repo: $REPO"

echo "==> labels"
declare -A LABELS=(
  [area:frontend]=1f6feb [area:backend]=8957e5 [area:infra]=0e8a16 [area:content]=fbca04 [area:docs]=5319e7
  [type:feat]=0e8a16 [type:fix]=d73a4a [type:chore]=c5def5 [type:docs]=0075ca [type:refactor]=bfd4f2
)
for name in "${!LABELS[@]}"; do
  gh label create "$name" --color "${LABELS[$name]}" --force >/dev/null
done

echo "==> milestones M0..M6"
declare -a MILESTONES=(
  "M0 — Bootstrap & governance"
  "M1 — Foundations"
  "M2 — Content (data)"
  "M3 — Pages & design"
  "M4 — i18n & translation"
  "M5 — Deployment"
  "M6 — Industrialization"
)
existing=$(gh api "repos/$REPO/milestones?state=all" -q '.[].title')
for title in "${MILESTONES[@]}"; do
  if ! grep -Fxq "$title" <<< "$existing"; then
    gh api -X POST "repos/$REPO/milestones" -f title="$title" >/dev/null
    echo "   created: $title"
  else
    echo "   exists:  $title"
  fi
done

echo "==> project board (v2)"
if titles=$(gh project list --owner "$OWNER" --format json -q '.projects[].title' 2>/dev/null); then
  if grep -Fxq "Portfolio" <<<"$titles"; then
    echo "   exists:  Portfolio"
  else
    gh project create --owner "$OWNER" --title "Portfolio" >/dev/null && echo "   created: Portfolio"
  fi
else
  echo "   skipped: needs 'project' scope (run: gh auth refresh -s project -h github.com)"
fi

echo "==> branch ruleset on main (PR-only) — requires a public repo or GitHub Pro for private repos"
# Canonical governance for main (create or converge — the live ruleset must match this file):
# PR-only (1 review, code owners, resolved threads, squash-only), no deletion, linear history,
# no force-push. Bypass: repo write role (owner) — needed by release-tag's PAT pushes (ADR 0010);
# the GitHub Actions app cannot be a bypass actor on a personal repo (organizations only).
ruleset_json() {
  cat <<'JSON'
{
  "name": "main",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "bypass_actors": [
    { "actor_id": 2, "actor_type": "RepositoryRole", "bypass_mode": "always" }
  ],
  "rules": [
    { "type": "pull_request", "parameters": { "required_approving_review_count": 1, "dismiss_stale_reviews_on_push": false, "required_reviewers": [], "require_code_owner_review": true, "require_last_push_approval": false, "required_review_thread_resolution": true, "allowed_merge_methods": ["squash"] } },
    { "type": "deletion" },
    { "type": "required_linear_history" },
    { "type": "non_fast_forward" }
  ]
}
JSON
}
rs_id=$(gh api "repos/$REPO/rulesets" -q '.[] | select(.name == "main") | .id' 2>/dev/null | head -1)
if [ -n "$rs_id" ]; then
  if ruleset_json | gh api -X PUT "repos/$REPO/rulesets/$rs_id" --input - >/dev/null 2>&1; then
    echo "   converged: main ruleset (id $rs_id)"
  else
    echo "   ERROR: failed to converge main ruleset (id $rs_id)"
  fi
elif ruleset_json | gh api -X POST "repos/$REPO/rulesets" --input - >/dev/null 2>&1; then
  echo "   created: main ruleset"
else
  echo "   skipped: server-side protection unavailable on a private free-plan repo."
  echo "            'make init' installs a local pre-push hook enforcing PR-only meanwhile;"
  echo "            re-run this after making the repo public (or on GitHub Pro) to enable it."
fi

echo "==> done."
