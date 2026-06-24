# Playbook — Secrets as a single source of truth with Infisical (free tier)

Reusable recipe to make **Infisical Cloud** the one place application secrets live, then derive both
the local `.env` and CI from it — **free, zero-ops, no long-lived root credential**. Generalizes to
any repo (this project applies it per ADR 0009).

## When to use

You have API keys a provider shows **only once** (Cloudflare/R2 tokens, PATs, beacon tokens) and you
keep re-pasting them into a hand-maintained `.env` and into GitHub Secrets. You want one durable,
private home and a reproducible way to fan them out — without paying or self-hosting.

## Prerequisites

- An Infisical account (free) and the CLI: `brew install infisical/get-cli/infisical`.
- `direnv` (loads the generated `.env`) and a `Makefile` + `scripts/` task runner.

## 1. One-time bootstrap (dashboard + CLI)

1. **Dashboard**: create a project (e.g. `<repo>-secrets`) with two environments — `dev` (local work)
   and `prod` (CI / deploy). Paste each one-time secret into the relevant environment.
2. **Login**: `infisical login` (browser OAuth — nothing stored in the repo).
3. **Link the repo**: `infisical init` at the repo root → writes `.infisical.json` (project id +
   default env, **no secret**). **Commit it** so the CLI targets the right project with no config.

> Non-US Cloud: pass `--domain https://eu.infisical.com` (or set `INFISICAL_DOMAIN`); the value is
> persisted in `.infisical.json`.

## 2. Generate the local `.env` from Infisical

Add a task that regenerates `.env` on demand (keep `.env` and `.env.*` gitignored):

```bash
# scripts/secrets-pull.sh  (pull_env isolated so it can be unit-tested with a stubbed CLI)
: "${INFISICAL_ENV:=dev}"; : "${ENV_FILE:=.env}"   # local default = dev; CI overrides with prod
pull_env() { infisical export --env="$1" --format=dotenv --output-file="$2" --silent; }
```

```make
secrets-pull: ## Regenerate the local .env from Infisical (the secrets source of truth)
	@./scripts/secrets-pull.sh
```

Workflow for any contributor: `infisical login` → `make secrets-pull` → direnv loads `.env`. The
`.env` is a disposable cache; the source of truth is Infisical.

> Prefer not writing a file at all? `infisical run -- <cmd>` injects secrets straight into a process,
> and `.envrc` can do `eval "$(infisical export --format=dotenv-export)"`. We generate a `.env` here
> because tools in the chain (Vite/Astro, wrangler via direnv) already consume one.

## 3. CI without long-lived secrets (GitHub Actions, OIDC)

1. **Dashboard**: create a **machine identity** with **OIDC** auth, trust scoped to the repo + ref.
2. **Workflow**: grant `permissions: id-token: write`, then fetch secrets at runtime — no static
   token in GitHub:

```yaml
permissions:
  contents: read
  id-token: write
steps:
  - uses: Infisical/secrets-action@<commit-sha>   # SHA-pinned
    with:
      method: oidc
      identity-id: ${{ '<machine-identity-id>' }}
      project-slug: <project-slug>
      env-slug: prod
  # secrets are now in the job env for subsequent steps
```

3. Delete the now-redundant GitHub Secrets/Variables.

## Guardrails & recovery

- **Never** commit a real secret; `.env` stays gitignored. `.infisical.json` is safe to commit (ids
  only).
- Infisical is external: mitigate with keys that are **regenerable at the source**, the **open-source
  self-host** escape hatch, and `infisical export` for an **offline backup** (free tier has no secret
  versioning).
- Verify: `make secrets-pull` writes a populated `.env`; `git check-ignore .env` confirms it is
  ignored; a CI dry-run shows secrets injected and masked.
