#!/usr/bin/env bats
# Unit tests for scripts/repo-settings-token.sh — hermetic: `gh` and `open` are stubbed on
# PATH, and each function runs in an isolated subshell that sources the script (so its `set -e` never
# leaks into bats). The gh stub records mutating `secret` calls to $STUB_CALLS, serves `secret list`
# from $STUB_SECRET_LIST, and simulates the tag-write probe via $STUB_CREATE_FAIL / $STUB_SHA_FAIL.

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../repo-settings-token.sh"
  STUB="$BATS_TEST_TMPDIR/bin"; mkdir -p "$STUB"
  export STUB_CALLS="$BATS_TEST_TMPDIR/calls"; : >"$STUB_CALLS"
  cat >"$STUB/gh" <<'STUB_EOF'
#!/usr/bin/env bash
if [[ "$1" == "api" ]]; then
  case "$*" in
    *commits/HEAD*)    [[ "${STUB_SHA_FAIL:-}" == 1 ]] && exit 1; echo "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef"; exit 0 ;;
    *POST*git/refs*)   [[ "${STUB_CREATE_FAIL:-}" == 1 ]] && exit 1; exit 0 ;;
    *DELETE*git/refs*) exit 0 ;;
    *"api user"*)      echo "gmocquet"; exit 0 ;;
    *) exit 0 ;;
  esac
fi
case "$1 $2" in
  "secret list")   printf '%s\n' "${STUB_SECRET_LIST:-}" ;;
  "secret set")    echo "set $3 --repo ${5:-}" >>"$STUB_CALLS" ;;
  "secret delete") [[ "${STUB_DELETE_FAIL:-}" == 1 ]] && exit 1; echo "delete $3 --repo ${5:-}" >>"$STUB_CALLS" ;;
esac
STUB_EOF
  chmod +x "$STUB/gh"
  printf '#!/usr/bin/env bash\nexit 0\n' >"$STUB/open"; chmod +x "$STUB/open"
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
  [[ "$output" == *"name=ci-gh-pat-token-gmocquet-portfolio"* ]]
  [[ "$output" == *"target_name=gmocquet"* ]]
  [[ "$output" == *"expires_in=none"* ]]
  [[ "$output" == *"contents=write"* ]]
  [[ "$output" == *"pull_requests=read"* ]]
}

@test "pat_url honours the PAT_EXPIRES_IN override" {
  run env PAT_EXPIRES_IN=90 bash -c 'source "$1"; pat_url gmocquet gmocquet-portfolio' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"expires_in=90"* ]]
}

@test "probe_tag_write succeeds when the API accepts the tag ref" {
  run bash -c 'source "$1"; probe_tag_write gmocquet/gmocquet-portfolio tok' _ "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "probe_tag_write fails when ref creation is rejected (mis-scoped PAT)" {
  run env STUB_CREATE_FAIL=1 bash -c 'source "$1"; probe_tag_write gmocquet/gmocquet-portfolio tok' _ "$SCRIPT"
  [ "$status" -ne 0 ]
}

@test "probe_tag_write fails when the token cannot even read the repo head" {
  run env STUB_SHA_FAIL=1 bash -c 'source "$1"; probe_tag_write gmocquet/gmocquet-portfolio tok' _ "$SCRIPT"
  [ "$status" -ne 0 ]
}

@test "status reports the secret set and points to the PAT in Developer settings" {
  run env STUB_SECRET_LIST=$'GH_PAT_TOKEN\t2026-07-10' \
    bash -c 'source "$1"; cmd_status gmocquet/gmocquet-portfolio' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"GH_PAT_TOKEN (Actions secret): set on gmocquet/gmocquet-portfolio"* ]]
  [[ "$output" == *"PAT 'ci-gh-pat-token-gmocquet-portfolio'"* ]]
  [[ "$output" == *"no API to list your own PATs"* ]]
  [[ "$output" == *"github.com/settings/personal-access-tokens"* ]]
}

@test "status reports the secret not set" {
  run bash -c 'source "$1"; cmd_status gmocquet/gmocquet-portfolio' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"GH_PAT_TOKEN (Actions secret): not set on gmocquet/gmocquet-portfolio"* ]]
}

@test "status lists what the supplied token grants (owner, kind, rights)" {
  run env STUB_SECRET_LIST=$'GH_PAT_TOKEN\t2026-07-10' GH_PAT_TOKEN=github_pat_abc \
    bash -c 'source "$1"; cmd_status gmocquet/gmocquet-portfolio' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"owner:"*"gmocquet"* ]]
  [[ "$output" == *"kind:"*"fine-grained"* ]]
  [[ "$output" == *"can create release tags"* ]]
}

@test "status flags a mis-scoped supplied token" {
  run env STUB_SECRET_LIST=$'GH_PAT_TOKEN\t2026-07-10' GH_PAT_TOKEN=github_pat_bad STUB_CREATE_FAIL=1 \
    bash -c 'source "$1"; cmd_status gmocquet/gmocquet-portfolio' _ "$SCRIPT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"NO — mis-scoped or invalid"* ]]
}

@test "delete removes the secret and points to the fine-grained tokens page" {
  run bash -c 'source "$1"; cmd_delete gmocquet/gmocquet-portfolio' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -qx "delete GH_PAT_TOKEN --repo gmocquet/gmocquet-portfolio" "$STUB_CALLS"
  [[ "$output" == *"github.com/settings/personal-access-tokens"* ]]
  [[ "$output" == *"ci-gh-pat-token-gmocquet-portfolio"* ]]
}

@test "delete still points to the tokens page when the secret is already gone" {
  run env STUB_DELETE_FAIL=1 bash -c 'source "$1"; cmd_delete gmocquet/gmocquet-portfolio' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already removed"* ]]
  [[ "$output" == *"github.com/settings/personal-access-tokens"* ]]
}

@test "SECRET_NAME override is respected" {
  run env SECRET_NAME=CUSTOM_PAT bash -c 'source "$1"; cmd_delete gmocquet/gmocquet-portfolio' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -qx "delete CUSTOM_PAT --repo gmocquet/gmocquet-portfolio" "$STUB_CALLS"
}
