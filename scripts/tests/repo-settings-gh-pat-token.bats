#!/usr/bin/env bats
# Unit tests for scripts/repo-settings-gh-pat-token.sh — hermetic: `gh` is stubbed on PATH, and each
# function is exercised in an isolated subshell that sources the script (so its `set -e` never leaks
# into bats). The gh stub records mutating calls to $STUB_CALLS and serves `secret list` from
# $STUB_SECRET_LIST.

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../repo-settings-gh-pat-token.sh"
  STUB="$BATS_TEST_TMPDIR/bin"; mkdir -p "$STUB"
  export STUB_CALLS="$BATS_TEST_TMPDIR/calls"; : >"$STUB_CALLS"
  cat >"$STUB/gh" <<'STUB_EOF'
#!/usr/bin/env bash
case "$1 $2" in
  "secret list")   printf '%s\n' "${STUB_SECRET_LIST:-}" ;;
  "secret set")    echo "set $3 --repo ${5:-}" >>"$STUB_CALLS" ;;
  "secret delete") echo "delete $3 --repo ${5:-}" >>"$STUB_CALLS" ;;
esac
STUB_EOF
  chmod +x "$STUB/gh"
  export PATH="$STUB:$PATH"
}

@test "urlencode percent-encodes reserved chars and keeps unreserved" {
  run bash -c 'source "$1"; urlencode "a b(c):d,e-f.g_h~i"' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "a%20b%28c%29%3Ad%2Ce-f.g_h~i" ]
}

@test "pat_url carries the fine-grained scope, name and target" {
  run bash -c 'source "$1"; pat_url gmocquet gmocquet-portfolio' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == "https://github.com/settings/personal-access-tokens/new?"* ]]
  [[ "$output" == *"name=gmocquet-portfolio-gh-pat-token"* ]]
  [[ "$output" == *"target_name=gmocquet"* ]]
  [[ "$output" == *"expires_in=none"* ]]
  [[ "$output" == *"contents=write"* ]]
}

@test "pat_url honours the PAT_EXPIRES_IN override" {
  run env PAT_EXPIRES_IN=90 bash -c 'source "$1"; pat_url gmocquet gmocquet-portfolio' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"expires_in=90"* ]]
}

@test "status reports the secret as set when gh lists it" {
  run env STUB_SECRET_LIST=$'GH_PAT_TOKEN\t2026-07-10' \
    bash -c 'source "$1"; cmd_status gmocquet/gmocquet-portfolio' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "GH_PAT_TOKEN: set on gmocquet/gmocquet-portfolio" ]
}

@test "status reports not set when gh lists nothing" {
  run bash -c 'source "$1"; cmd_status gmocquet/gmocquet-portfolio' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "GH_PAT_TOKEN: not set on gmocquet/gmocquet-portfolio" ]
}

@test "delete calls gh secret delete with the secret name and repo" {
  run bash -c 'source "$1"; cmd_delete gmocquet/gmocquet-portfolio' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -qx "delete GH_PAT_TOKEN --repo gmocquet/gmocquet-portfolio" "$STUB_CALLS"
}

@test "SECRET_NAME override is respected" {
  run env SECRET_NAME=CUSTOM_PAT bash -c 'source "$1"; cmd_delete gmocquet/gmocquet-portfolio' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -qx "delete CUSTOM_PAT --repo gmocquet/gmocquet-portfolio" "$STUB_CALLS"
}
