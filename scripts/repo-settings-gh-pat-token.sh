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
  name="ci-gh-pat-token-${repo_name}"
  desc="CI token for ${repo_name}. Used by the release-tag GitHub Actions workflow to push v* release tags so the deploy workflow triggers (the automatic GITHUB_TOKEN cannot trigger downstream workflows). Scope: Contents read and write on ${repo_name} only."
  printf 'https://github.com/settings/personal-access-tokens/new?name=%s&description=%s&target_name=%s&expires_in=%s&contents=write\n' \
    "$(urlencode "$name")" "$(urlencode "$desc")" "$owner" "$PAT_EXPIRES_IN"
}

# tokens_url — echo the fine-grained PAT management page (there is no API to delete a user's own PAT).
tokens_url() { printf 'https://github.com/settings/personal-access-tokens\n'; }

# open_url <url> — open in the default browser, or print it when no opener is available.
open_url() {
  if command -v open >/dev/null 2>&1; then open "$1"
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$1"
  else echo "Open this URL: $1"; fi
}

# probe_tag_write <repo> <token> — return 0 iff <token> can create a tag ref on <repo>, exercised
# exactly as the release workflow does (POST git/refs, the call that 404'd with a mis-scoped PAT).
# Creates then deletes a throwaway NON-`v*` tag, so it triggers no workflow (deploy/changelog watch
# `v*`) and leaves no trace. This is the real proof of Contents:write — a stored Actions secret is
# write-only and cannot be read back to inspect its scopes.
probe_tag_write() {
  local repo="$1" token="$2" name="gh-pat-token-permcheck-$$-${RANDOM}" sha
  sha="$(GH_TOKEN="$token" gh api "repos/$repo/commits/HEAD" --jq '.sha' 2>/dev/null)" || return 1
  GH_TOKEN="$token" gh api -X POST "repos/$repo/git/refs" \
    -f ref="refs/tags/$name" -f sha="$sha" >/dev/null 2>&1 || return 1
  GH_TOKEN="$token" gh api -X DELETE "repos/$repo/git/refs/tags/$name" >/dev/null 2>&1 || true
  return 0
}

# cmd_set <owner> <repo> — guide the PAT creation, then store it via gh's native prompt (masked
# input, ✓ on success). Verify the token's rights afterwards with `status` (see cmd_status).
cmd_set() {
  local owner="$1" repo="$2" name="${2##*/}"
  echo "==> $SECRET_NAME — fine-grained PAT so CI can push v* release tags that trigger deploy."
  echo "    Scope: Contents read/write on $repo only. Stored as a GitHub Actions secret."
  echo ""
  echo "Opening the pre-filled PAT page (name, description, No expiration and Contents: Read and write"
  echo "are set). GitHub cannot pre-select the repository, so you still need to:"
  echo "  - set Repository access -> Only select repositories -> $repo"
  echo "  - click Generate token, then copy it."
  echo ""
  open_url "$(pat_url "$owner" "$name")"
  printf "Press Enter once the token is generated and copied... "; read -r _
  echo "Paste the token when prompted (input is masked):"
  gh secret set "$SECRET_NAME" --repo "$repo"
  echo ""
  echo "==> stored $SECRET_NAME on $repo. Next steps:"
  echo "  1. Verify the token locally: GH_PAT_TOKEN=<token> make repo-settings-gh-pat-token-status"
  echo "  2. On the next push/merge to main, release-tag creates a v* tag with this PAT -> deploy runs."
}

# cmd_status <repo> — report whether the Actions secret exists and, when a token is supplied in the
# environment (GH_PAT_TOKEN), verify it actually has Contents:write. The stored secret's value is
# write-only, so its rights cannot be checked from here without the token in hand.
cmd_status() {
  local repo="$1"
  if gh secret list --repo "$repo" | grep -q "^${SECRET_NAME}[[:space:]]"; then
    echo "$SECRET_NAME: set on $repo"
  else
    echo "$SECRET_NAME: not set on $repo"
    return 0
  fi
  if [[ -n "${GH_PAT_TOKEN:-}" ]]; then
    if probe_tag_write "$repo" "$GH_PAT_TOKEN"; then
      echo "$SECRET_NAME: rights OK — the supplied token can create tags on $repo"
    else
      echo "$SECRET_NAME: rights INSUFFICIENT — the supplied token cannot create tags on $repo" >&2
      echo "  Fix: Repository access -> Only select repositories -> $repo; Contents: Read and write." >&2
      return 1
    fi
  else
    echo "  rights not checked: Actions secrets are write-only. \`set\` verifies at store time; or run"
    echo "  \`GH_PAT_TOKEN=<token> make repo-settings-gh-pat-token-status\` to probe a token now."
  fi
}

# cmd_delete <repo> — remove the Actions secret, then open the fine-grained PAT page so the user can
# revoke the token itself. GitHub exposes no API to delete a user's own PAT, so this step is manual.
cmd_delete() {
  local repo="$1" name="ci-gh-pat-token-${1##*/}" url
  if gh secret delete "$SECRET_NAME" --repo "$repo" 2>/dev/null; then
    echo "==> deleted the $SECRET_NAME Actions secret from $repo"
  else
    echo "==> $SECRET_NAME Actions secret not found on $repo (already removed?)"
  fi
  url="$(tokens_url)"
  echo ""
  echo "GitHub has no API to delete a personal access token — revoke it in the browser:"
  echo "  find the fine-grained token named '$name' (or whichever you created), open it, and Delete."
  echo "  $url"
  open_url "$url"
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
