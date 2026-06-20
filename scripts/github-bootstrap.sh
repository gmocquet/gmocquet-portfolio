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

echo "==> branch protection on main (PR required, 0 approvals — solo-friendly)"
if gh api -X PUT "repos/$REPO/branches/main/protection" \
  -H "Accept: application/vnd.github+json" \
  -F "required_pull_request_reviews[required_approving_review_count]=0" \
  -F "required_status_checks=null" \
  -F "enforce_admins=false" \
  -F "restrictions=null" >/dev/null 2>&1; then
  echo "   protection set"
else
  echo "   skipped: could not set protection (needs admin rights / token scope)"
fi

echo "==> done."
