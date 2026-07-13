#!/usr/bin/env bats
# Unit tests for scripts/changelog.sh — hermetic: `gh` and `git-cliff` (invoked as `git cliff`) are
# stubbed on PATH. The gh stub answers `repo view` and the `pulls` pre-check (fail via
# $STUB_PULLS_FAIL); the git-cliff stub records its args to $STUB_CALLS and writes nothing.

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../changelog.sh"
  STUB="$BATS_TEST_TMPDIR/bin"; mkdir -p "$STUB"
  export STUB_CALLS="$BATS_TEST_TMPDIR/calls"; : >"$STUB_CALLS"
  cat >"$STUB/gh" <<'EOF'
#!/usr/bin/env bash
case "$*" in
  "repo view"*)         echo "gmocquet/gmocquet-portfolio" ;;
  "api repos/"*pulls*)  [[ "${STUB_PULLS_FAIL:-}" == 1 ]] && exit 1; exit 0 ;;
  *) exit 0 ;;
esac
EOF
  chmod +x "$STUB/gh"
  cat >"$STUB/git-cliff" <<'EOF'
#!/usr/bin/env bash
echo "git-cliff $*" >>"$STUB_CALLS"
EOF
  chmod +x "$STUB/git-cliff"
  export PATH="$STUB:$PATH"
}

@test "changelog fails (with setup instructions) when GH_PAT_TOKEN is unset" {
  run env -u GH_PAT_TOKEN bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"GH_PAT_TOKEN is not set"* ]]
  [[ "$output" == *"make repo-settings-token-set"* ]]
  [ ! -s "$STUB_CALLS" ]                 # git-cliff never invoked
}

@test "changelog fails when the PAT cannot read pull requests" {
  run env GH_PAT_TOKEN=tok STUB_PULLS_FAIL=1 bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Pull requests: Read"* ]]
  [ ! -s "$STUB_CALLS" ]                 # bailed out before git-cliff
}

@test "changelog runs git-cliff with the PAT and TAG when everything is OK" {
  run env GH_PAT_TOKEN=tok bash "$SCRIPT" v1.2.3
  [ "$status" -eq 0 ]
  grep -q -- "--github-token tok" "$STUB_CALLS"
  grep -q -- "--tag v1.2.3" "$STUB_CALLS"
}

@test "changelog runs git-cliff without --tag when no TAG is passed" {
  run env GH_PAT_TOKEN=tok bash "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q -- "--github-token tok" "$STUB_CALLS"
  ! grep -q -- "--tag" "$STUB_CALLS"
}
