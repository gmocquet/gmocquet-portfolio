#!/usr/bin/env bash
# next-release-tag — print the next release tag (vX.Y.Z) to create, or nothing when no release is
# warranted. Used by .github/workflows/release-tag.yml.
#
# Bootstrap: when the repo has NO tag yet, git-cliff computes 0.1.0 but errors on its default tag
# pattern (v[0-9]*) because it can't infer the `v` prefix without an existing tag — so we return the
# initial tag directly. Once a v* tag exists, git-cliff drives the bumps (it infers the prefix).
#
# `next_release_tag` is kept isolated so bats can stub `git` (incl. `git cliff`) and unit-test it.
set -euo pipefail

: "${INITIAL_TAG:=v0.1.0}"

# next_release_tag — echo the tag to create, or nothing if no release is warranted.
next_release_tag() {
  local last next
  last="$(git describe --tags --abbrev=0 2>/dev/null || true)"
  if [[ -z "$last" ]]; then
    printf '%s\n' "$INITIAL_TAG"          # no tag yet → bootstrap the initial release
    return 0
  fi
  next="$(git cliff --bumped-version 2>/dev/null || true)"
  [[ -z "$next" ]] && return 0            # git-cliff produced nothing → nothing to release
  [[ "$next" == v* ]] || next="v$next"    # ensure the v prefix
  [[ "$next" == "$last" ]] && return 0    # no version change → nothing to release
  printf '%s\n' "$next"
}

# Only run when executed directly (sourcing exposes next_release_tag for bats).
if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
  next_release_tag
fi
