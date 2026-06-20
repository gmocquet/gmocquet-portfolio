#!/usr/bin/env bash
# deploy — build the static frontend and deploy to Cloudflare Pages via wrangler.
# Used identically by `make deploy` and the deploy.yml workflow (single source of commands).
set -euo pipefail
cd "$(dirname "$0")/.."

: "${CF_PAGES_PROJECT:=guillaumemocquet}"

npm --prefix frontend run build
npx --prefix frontend wrangler pages deploy frontend/dist --project-name "$CF_PAGES_PROJECT"
