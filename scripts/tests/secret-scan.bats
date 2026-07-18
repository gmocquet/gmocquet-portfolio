#!/usr/bin/env bats
# Unit tests for scripts/secret-scan.sh — hermetic: gitleaks is stubbed on PATH (it only records the
# args it was called with), so nothing scans a real repo or hits the network. Covers the pure arg
# builder and both modes, plus the "tool absent -> skip, never block" behaviour.

setup() {
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO/scripts" "$REPO/bin"
  cp "$BATS_TEST_DIRNAME/../secret-scan.sh" "$REPO/scripts/secret-scan.sh"
  SCRIPT="$REPO/scripts/secret-scan.sh"

  # Stub gitleaks: record the args it was invoked with (and succeed).
  export ARGS_FILE="$REPO/args"
  cat >"$REPO/bin/gitleaks" <<'STUB'
#!/usr/bin/env bash
echo "$@" >>"$ARGS_FILE"
STUB
  chmod +x "$REPO/bin/gitleaks"
  export PATH="$REPO/bin:$PATH"
}

@test "gitleaks_args full scans the whole history (all refs), not staged" {
  source "$SCRIPT"
  run gitleaks_args full
  [ "$status" -eq 0 ]
  [[ "$output" == *"--log-opts=--all"* ]]
  [[ "$output" != *"--staged"* ]]
}

@test "gitleaks_args staged scans staged changes only" {
  source "$SCRIPT"
  run gitleaks_args staged
  [ "$status" -eq 0 ]
  [[ "$output" == *"--staged"* ]]
  [[ "$output" != *"--log-opts"* ]]
}

@test "default run invokes gitleaks in full-history mode" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$(cat "$ARGS_FILE")" == *"git --log-opts=--all"* ]]
}

@test "--staged run invokes gitleaks in staged mode" {
  run bash "$SCRIPT" --staged
  [ "$status" -eq 0 ]
  [[ "$(cat "$ARGS_FILE")" == *"git --staged"* ]]
}

@test "missing gitleaks skips without blocking (rc 0)" {
  bash_bin="$(command -v bash)"   # resolve before clobbering PATH so env can still exec bash
  run env PATH="/usr/bin:/bin" "$bash_bin" "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gitleaks not found"* ]]
}
