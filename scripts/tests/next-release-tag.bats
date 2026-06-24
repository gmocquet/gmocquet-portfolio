#!/usr/bin/env bats
# Unit tests for scripts/next-release-tag.sh — hermetic: `git` is stubbed on PATH and driven by
# STUB_LAST (latest tag) and STUB_SUBJECTS / STUB_BODIES (the commits since that tag).

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../next-release-tag.sh"
  STUB="$BATS_TEST_TMPDIR/bin"; mkdir -p "$STUB"
  cat >"$STUB/git" <<'STUB_EOF'
#!/usr/bin/env bash
case "$1" in
  describe) [[ -n "${STUB_LAST:-}" ]] && { printf '%s\n' "$STUB_LAST"; exit 0; } || exit 128 ;;
  log)
    case "$*" in
      *%H*) [[ -n "${STUB_SUBJECTS:-}" ]] && echo "0000000000000000000000000000000000000000" ;;
      *%s*) printf '%s\n' "${STUB_SUBJECTS:-}" ;;
      *)    printf '%s\n' "${STUB_BODIES:-}" ;;
    esac
    exit 0 ;;
  *) exit 0 ;;
esac
STUB_EOF
  chmod +x "$STUB/git"
  export PATH="$STUB:$PATH"
}

@test "no existing tag bootstraps v0.0.1" {
  export STUB_LAST=""
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "v0.0.1" ]
}

@test "default bump is patch (fix)" {
  export STUB_LAST="v0.1.0" STUB_SUBJECTS="fix(ci): silence a warning"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "v0.1.1" ]
}

@test "default bump is patch (chore/docs/ci)" {
  export STUB_LAST="v1.2.3" STUB_SUBJECTS="chore: bump deps"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "v1.2.4" ]
}

@test "feat bumps the minor and resets patch" {
  export STUB_LAST="v0.1.5" STUB_SUBJECTS="feat(ui): add a search box"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "v0.2.0" ]
}

@test "breaking marker (type!:) bumps the major" {
  export STUB_LAST="v0.4.2" STUB_SUBJECTS="feat(api)!: drop the legacy endpoint"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "v1.0.0" ]
}

@test "BREAKING CHANGE in the body bumps the major" {
  export STUB_LAST="v2.3.4" STUB_SUBJECTS="fix: tweak default" STUB_BODIES="BREAKING CHANGE: config key renamed"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "v3.0.0" ]
}

@test "highest bump wins across the range (feat + breaking -> major)" {
  export STUB_LAST="v0.1.0" STUB_SUBJECTS=$'feat: a\nfix!: b'
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "v1.0.0" ]
}

@test "the words BREAKING CHANGE in prose (not a footer) do not bump major" {
  export STUB_LAST="v0.1.0" STUB_SUBJECTS="feat(ci): explain the policy" \
    STUB_BODIES="This commit documents how a BREAKING CHANGE footer is detected."
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "v0.2.0" ]
}

@test "no commits since the tag yields nothing" {
  export STUB_LAST="v0.1.0" STUB_SUBJECTS=""
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
