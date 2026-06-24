#!/usr/bin/env bats
# Unit tests for scripts/secrets-pull.sh — fully hermetic: the script is copied into a temp "repo"
# and `infisical` is stubbed on PATH, so nothing hits the network or the real Infisical project.

setup() {
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO/scripts" "$REPO/bin"
  cp "$BATS_TEST_DIRNAME/../secrets-pull.sh" "$REPO/scripts/secrets-pull.sh"
  SCRIPT="$REPO/scripts/secrets-pull.sh"

  # Stub: record args, and honor --output-file by writing a dummy dotenv there.
  export ARGS_FILE="$REPO/args"
  cat >"$REPO/bin/infisical" <<'STUB'
#!/usr/bin/env bash
echo "$@" >>"$ARGS_FILE"
for a in "$@"; do case "$a" in --output-file=*) printf 'KEY=value\n' >"${a#--output-file=}";; esac; done
STUB
  chmod +x "$REPO/bin/infisical"
  export PATH="$REPO/bin:$PATH"
}

@test "pull_env exports the given env in dotenv format to the given file" {
  source "$SCRIPT"   # main guard skipped when sourced; no cd, no pull
  run pull_env dev "$REPO/out.env"
  [ "$status" -eq 0 ]
  [ "$(cat "$ARGS_FILE")" = "export --env=dev --format=dotenv --output-file=$REPO/out.env --silent" ]
}

@test "running the script errors when .infisical.json is missing" {
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *".infisical.json not found"* ]]
}

@test "running the script writes .env from Infisical (default env=dev)" {
  : >"$REPO/.infisical.json"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ -f "$REPO/.env" ]
  [[ "$(cat "$ARGS_FILE")" == *"--env=dev"* ]]
}
