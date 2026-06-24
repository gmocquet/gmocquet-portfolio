# 0009 — Application secrets in Infisical (single source of truth; .env generated, CI via OIDC)

- **Status**: Accepted (2026-06-24).

## Context

Application secrets — the Cloudflare deploy token + account id, the R2 S3 keys for the OpenTofu
backend (ADR 0008), the Web Analytics beacon token, and an optional Anthropic API key — were spread
across two hand-maintained places: a local `.env` (gitignored, loaded by direnv) and GitHub Actions
**Secrets/Variables**. The same value had to be pasted in both, with no single source of truth and,
worse, **no durable home for keys a provider shows only once** (an R2 token, a PAT): lose the `.env`
and the key is gone. A committed cleartext secret is never an option. We want a **free, zero-ops**
store that is the one place a secret lives, from which both local dev and CI derive.

Options weighed: **Doppler** (excellent DX but proprietary → vendor lock-in, against our
reproducibility principle), **Bitwarden** (splits archive and programmatic access across two
products), **HCP Vault Secrets** (**end-of-life 2026-07-01** — excluded), self-hosted Vault/Infisical
(infra to run — overkill for a solo project). **Infisical Cloud** wins: one product covers the
dashboard archive **and** programmatic fetch, **open source (MIT)** so there is a self-host escape
hatch, and the free tier comfortably fits a solo operator (5 machine identities, 3 projects, 3
environments, 10 native integrations, **unlimited secrets**; no secret versioning).

## Decision

**Infisical Cloud (free tier) is the single source of truth for all application secrets** — project
`gmocquet-portfolio-secrets`, environment `prod`. Nothing else holds a master copy.

- **Repo link**: `infisical init` writes **`.infisical.json`** (project id + default environment,
  **no secret**) — committed, so `export`/`run` target the right project with no manual config.
- **Local**: `make secrets-pull` → `scripts/secrets-pull.sh` runs
  `infisical export --env=prod --format=dotenv --output-file=.env`. The `.env` is **generated,
  gitignored and ephemeral** (regenerated on demand); direnv loads it exactly as before, so the
  developer workflow is unchanged — only the file's *source* moves to Infisical.
- **CI**: the official `Infisical/secrets-action` (SHA-pinned) fetches secrets at runtime via
  **OIDC** (the job uses `id-token: write`); the long-lived `CLOUDFLARE_*` GitHub Secrets/Variables
  are removed. No static secret is stored in GitHub.
- **Auth model**: local = `infisical login` (browser OAuth, no stored secret); CI = OIDC (short-lived
  GitHub-issued token). There is therefore **no long-lived root credential to keep safe** — which is
  exactly what closes the "secret shown only once" problem.

## Consequences

- One durable, private home for every secret, including one-time-view keys; copy/paste duplication
  between local and CI disappears.
- `.env` is no longer authored by hand — it is a disposable cache; a new operator runs
  `infisical login` then `make secrets-pull` (documented in `README.md` and the playbook).
- External SaaS dependency. Mitigations: the stored values are **regenerable at their source**
  (Cloudflare, Anthropic…); Infisical is **open source** (self-host fallback); `infisical export`
  can dump an offline backup. The free tier has **no secret versioning**, so there is no server-side
  history — the source providers + IaC remain the ultimate recovery path.
- `make doctor` gains an Infisical presence + authentication check (non-blocking warning).
- Independent of ADR 0008: the R2 S3 keys for the tofu backend are now also stored in Infisical, but
  the state backend itself is unchanged.
