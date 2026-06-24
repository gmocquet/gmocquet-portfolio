#!/usr/bin/env bash
# next-release-tag — print the next release tag (vMAJOR.MINOR.PATCH) to create from the Conventional
# Commits merged since the last tag, or nothing when there is nothing to release. Used by
# .github/workflows/release-tag.yml (the repo squash-merges, so each commit's subject is a PR title).
#
# Bump policy (Conventional Commits; the highest match across the range wins):
#   - breaking change  (`type!:` in a subject, or `BREAKING CHANGE` in a body)  -> MAJOR
#   - a `feat` commit                                                           -> MINOR
#   - anything else    (fix, chore, docs, ci, refactor, …)                      -> PATCH  (default)
#
# Bootstrap: with no tag yet, return the initial tag (v0.0.1).
#
# Logic is isolated so bats can stub `git` and unit-test it.
set -euo pipefail

: "${INITIAL_TAG:=v0.0.1}"

# bump_kind <range> — echo major|minor|patch from the Conventional Commits in the git range.
bump_kind() {
  local range="$1" subjects bodies
  subjects="$(git log --format='%s' "$range" 2>/dev/null || true)"
  bodies="$(git log --format='%B' "$range" 2>/dev/null || true)"
  # Breaking = a `type!:` subject, or a real `BREAKING CHANGE:` footer (line start + colon) — not the
  # mere mention of the words in prose.
  if grep -qE '^[a-z]+(\([^)]+\))?!:' <<<"$subjects" || grep -qE '^BREAKING[ -]CHANGE:' <<<"$bodies"; then
    echo major
  elif grep -qE '^feat(\([^)]+\))?:' <<<"$subjects"; then
    echo minor
  else
    echo patch
  fi
}

# next_release_tag — echo the tag to create, or nothing if no release is warranted.
next_release_tag() {
  local last major minor patch
  last="$(git describe --tags --abbrev=0 2>/dev/null || true)"
  if [[ -z "$last" ]]; then
    printf '%s\n' "$INITIAL_TAG"             # no tag yet → bootstrap the initial release
    return 0
  fi
  IFS=. read -r major minor patch <<<"${last#v}"
  [[ "$major" =~ ^[0-9]+$ && "$minor" =~ ^[0-9]+$ && "$patch" =~ ^[0-9]+$ ]] || return 0
  [[ -n "$(git log --format='%H' "${last}..HEAD" 2>/dev/null)" ]] || return 0  # nothing new → no release
  case "$(bump_kind "${last}..HEAD")" in
    major) printf 'v%s.0.0\n' "$((major + 1))" ;;
    minor) printf 'v%s.%s.0\n' "$major" "$((minor + 1))" ;;
    patch) printf 'v%s.%s.%s\n' "$major" "$minor" "$((patch + 1))" ;;
  esac
}

# Only run when executed directly (sourcing exposes the functions for bats).
if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
  next_release_tag
fi
