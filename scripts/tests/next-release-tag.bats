#!/usr/bin/env bats
# Unit tests for scripts/next-release-tag.sh — hermetic: `git` (incl. `git cliff`) is stubbed on
# PATH and driven by STUB_LAST (latest tag) / STUB_NEXT (git-cliff --bumped-version output).

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../next-release-tag.sh"
  STUB="$BATS_TEST_TMPDIR/bin"; mkdir -p "$STUB"
  cat >"$STUB/git" <<'STUB_EOF'
#!/usr/bin/env bash
case "$1" in
  describe) [[ -n "${STUB_LAST:-}" ]] && { printf '%s\n' "$STUB_LAST"; exit 0; } || exit 128 ;;
  cliff)    [[ -n "${STUB_NEXT:-}" ]] && { printf '%s\n' "$STUB_NEXT"; exit 0; } || exit 1 ;;
  *)        exit 0 ;;
esac
STUB_EOF
  chmod +x "$STUB/git"
  export PATH="$STUB:$PATH"
}

@test "no existing tag bootstraps v0.1.0" {
  export STUB_LAST="" STUB_NEXT=""
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "v0.1.0" ]
}

@test "existing tag + git-cliff bump yields a v-prefixed next" {
  export STUB_LAST="v0.1.0" STUB_NEXT="0.2.0"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "v0.2.0" ]
}

@test "existing tag + same computed version yields nothing" {
  export STUB_LAST="v0.1.0" STUB_NEXT="v0.1.0"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "existing tag + empty git-cliff output yields nothing" {
  export STUB_LAST="v0.1.0" STUB_NEXT=""
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
