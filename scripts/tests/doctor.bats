#!/usr/bin/env bats
# Unit tests for the pure-ish helpers in scripts/doctor.sh (sourcing skips the guarded main()).

DOCTOR="${BATS_TEST_DIRNAME}/../doctor.sh"

setup() { source "$DOCTOR"; }

@test "has_cmd finds an existing command" {
  run has_cmd bash
  [ "$status" -eq 0 ]
}

@test "has_cmd rejects a missing command" {
  run has_cmd definitely-not-a-real-command-xyz
  [ "$status" -ne 0 ]
}

@test "infisical_auth_ok fails when the infisical CLI is absent" {
  bash_bin="$(command -v bash)"   # resolve before clobbering PATH so env can still exec bash
  run env PATH="/nonexistent" "$bash_bin" -c "source '$DOCTOR'; infisical_auth_ok"
  [ "$status" -eq 1 ]
}

@test "infisical_auth_ok succeeds when infisical returns a token" {
  stub="$BATS_TEST_TMPDIR/bin"; mkdir -p "$stub"
  cat >"$stub/infisical" <<'STUB'
#!/usr/bin/env bash
[ "$1 $2 $3" = "user get token" ] && exit 0 || exit 1
STUB
  chmod +x "$stub/infisical"
  run env PATH="$stub:$PATH" bash -c "source '$DOCTOR'; infisical_auth_ok"
  [ "$status" -eq 0 ]
}
