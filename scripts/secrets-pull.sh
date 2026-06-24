#!/usr/bin/env bash
# secrets-pull — regenerate the local .env from Infisical, the single source of truth for secrets.
# Pulls one environment's secrets and writes them to .env (gitignored); direnv then loads it as before.
# `pull_env` is the only side-effecting unit (the infisical call), kept isolated so bats can stub it.
# Prerequisites: `infisical login` (once) + `infisical init` (creates .infisical.json, committed).
# Defaults to the `dev` environment for local work; override with INFISICAL_ENV=prod (CI uses prod).
set -euo pipefail

: "${INFISICAL_ENV:=dev}"
: "${ENV_FILE:=.env}"

# pull_env <environment> <output-file> — export the env's secrets from Infisical into a dotenv file.
pull_env() {
  infisical export --env="$1" --format=dotenv --output-file="$2" --silent
}

# Only run when executed directly (sourcing exposes pull_env for bats, without cd'ing or pulling).
if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
  cd "$(dirname "$0")/.."
  if [[ ! -f .infisical.json ]]; then
    printf 'error: .infisical.json not found — run `infisical login` then `infisical init` first.\n' >&2
    exit 1
  fi
  pull_env "$INFISICAL_ENV" "$ENV_FILE"
  printf '  \033[32m✓\033[0m wrote %s from Infisical (env=%s)\n' "$ENV_FILE" "$INFISICAL_ENV"
fi
