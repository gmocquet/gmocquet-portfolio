# guillaumemocquet.com — Portfolio

Professional portfolio of **Guillaume Mocquet**, built and operated as a reproducible,
agentic-coding reference project.

> This `README.md` is the **single source of business context**. It is imported into the assistant
> context at launch via `@README.md` from the root `CLAUDE.md` (knowledge lives in flat, versioned
> files in this repo — never in external memory).

## Positioning (drives content, tone and engineering rigor)

- **Career target — Engineering Manager, Data/AI · Platform & DevEx.** The current role of
  **Staff Data Engineer (5+ years)** is the recent, proximate technical foundation that credibilizes
  the move to EM. Profile: technical expert on **Data/AI/Platform/DevEx** topics.
- **Site message — EM-first, carried by technical excellence.** Hero, value proposition and project
  framing emphasize leadership, platform thinking, developer experience and technical mastery — not
  only individual-contributor data engineering.
- **Agentic Coding** is a secondary proof point (this site is built with a piloted team of expert
  agents) — mentioned soberly on `/colophon`, never the headline.

## Dual purpose of this project

1. **Portfolio / showcase** of professional experience (the visible deliverable — Lot 1).
2. **Technology demonstrator + reusable base** — this repo is designed to be a starter for future
   websites and **frontend/backend SaaS apps** on **Python / TypeScript / React**. This is what
   justifies the architectural rigor (typed contracts, ports/adapters, IaC, CI/CD, agent team)
   beyond a simple showcase.

## Scope

This repo is delivered in increments. **Lot 1 (current)** covers only the **public showcase site**
(no private area, no tracking). Out of scope for now, in order: private area (token-based access with
configurable validity, back-office, revocation) → tracking → blog + admin.

## Stack (Lot 1)

- **Frontend** (`frontend/`): Astro 6 (static output) + React islands (`@astrojs/react`),
  Tailwind CSS v4 (`@tailwindcss/vite`), shadcn/ui + Magic UI (disciplined), Motion. Bilingual
  (EN source, FR generated via an idempotent Claude-powered CLI). Content is **YAML data** decoupled
  from presentation, validated by Zod (fail-fast).
- **Backend** (`backend/`): Python/FastAPI + Pydantic v2 — **anticipated skeleton only** in Lot 1,
  implemented in Lot 2 (private area).
- **Hosting**: Cloudflare Pages (free tier) + Cloudflare Web Analytics; domain
  `guillaumemocquet.com` (DNS delegated OVH → Cloudflare).

## Repository layout

Two independent, self-contained ecosystems, each extractable to its own repo:

```
frontend/   # TS/React/Astro ecosystem (public site + packages/ui component library)
backend/    # Python/FastAPI ecosystem (skeleton in Lot 1)
content/    # lives under frontend/ — human-friendly YAML content (data, decoupled from UI)
docs/       # ADRs (docs/adrs), playbooks (docs/playbook), agentic build log
scripts/    # implementations invoked by the Makefile (doctor, github-bootstrap, …)
openspec/   # spec-driven change proposals
```

See `docs/adrs/` for the structural decisions.

## Requirements

Global tooling for macOS — install [Homebrew](https://brew.sh) first, then each tool below. Run
`make doctor` afterwards to verify tooling and access (GitHub SSH, Anthropic OAuth/API key).

| Tool | Purpose | Install |
|------|---------|---------|
| **fnm** (+ Node 24.17.0) | JS runtime for the frontend | `brew install fnm` then `fnm install` (reads `.node-version`) |
| **uv** | Python toolchain (backend + Python dev tools) | `brew install uv` |
| **gh** | GitHub CLI (governance, PRs) | `brew install gh` then `gh auth login` |
| **direnv** | auto-loads `.env` via `.envrc` | `brew install direnv` (add the shell hook, then `direnv allow`) |
| **git-cliff** | CHANGELOG generation | `brew install git-cliff` |
| **bats-core** | Bash unit tests | `brew install bats-core` |
| **openspec** | spec-driven workflow CLI | `brew install openspec` |
| **tenv** | Terraform/OpenTofu version manager (later lots) | `brew install tenv` |
| **git-filter-repo** | git history rewrites (e.g. purge a committed file from history) | `brew install git-filter-repo` |
| **infisical** | secrets source of truth (generate `.env`, CI) | `brew install infisical/get-cli/infisical` |

**Project dev tools are NOT global** — they are pinned dev dependencies installed by `make init`:

- **pre-commit** — pinned in each ecosystem's `pyproject.toml` (uv-managed Python), run via
  `uv run pre-commit`.
- **wrangler** — pinned in `frontend/package.json` (`devDependencies`), run via `npx wrangler`.
- Plus per-ecosystem deps: `ruff` + `pytest` (backend, uv) and Astro / Biome / etc. (frontend, npm).

## Getting started

Prerequisites and per-stack setup are documented in `frontend/CONTRIBUTING.md` and
`backend/CONTRIBUTING.md` (focus macOS 26.5.1). The **`Makefile`** is the single entry point for all
actions; run `make help` to list targets.

```bash
make doctor   # preflight: required tools + access (GitHub SSH, Anthropic OAuth or API key)
make init     # install dependencies + pre-commit hooks (per ecosystem)
make dev      # run the frontend site locally
make build    # produce the static site
make lint     # auto-format + lint + pre-commit checks (per ecosystem)
```

## Deployment

Hosting is **Cloudflare Pages** (see ADR 0002/0005/0007). **DNS is delegated to Cloudflare; mail stays
at OVH** — the OVH MX/SPF/DKIM/SRV records are replicated into Cloudflare, so apex + `www` are served
directly over HTTPS while email is untouched. Three parts:

- **Platform & DNS as IaC** — `infra/cloudflare/` (OpenTofu) provisions the zone, the Pages project, the
  apex + `www` custom domains and DNS records, and the replicated mail records. See
  `infra/cloudflare/README.md` for the apply + DNSSEC-safe migration runbook and token scopes.
- **Registrar (OVH)** — delegate the nameservers OVH → Cloudflare (after disabling DNSSEC and waiting for
  the DS to expire — see the runbook). Mailboxes stay at OVH.
- **Release-driven deploy** — `.github/workflows/deploy.yml` runs `make deploy` (build + `wrangler`
  Direct Upload) on every **`v*` release tag** (tags are created by `release-tag.yml` from
  Conventional Commits). `release-tag.yml` pushes the tag with a **fine-grained PAT**
  (`GH_PAT_TOKEN`, managed by `make repo-settings-gh-pat-token-*`) rather than the automatic
  `GITHUB_TOKEN`, because GitHub does not trigger workflows from `GITHUB_TOKEN`-created events — see
  ADR 0010. Deploy needs the `CLOUDFLARE_API_TOKEN` / `CLOUDFLARE_ACCOUNT_ID` secrets and the
  optional `PUBLIC_CF_BEACON_TOKEN` variable (cookieless analytics beacon). `make deploy` also works
  locally (the secrets come from your generated `.env` — see **Secrets**).

## Secrets

Application secrets live in **Infisical** (free tier) as the **single source of truth** — project
`gmocquet-portfolio-secrets`, with two environments: **`dev`** (local) and **`prod`** (CI / deploy).
They are never committed; the local `.env` is **generated** from Infisical, never hand-written
(`.env` / `.env.*` stay gitignored).

First-time setup: `infisical login`, then `infisical init` at the repo root (writes the committed
`.infisical.json` — project id only, no secret). Day to day:

```bash
make secrets-pull                    # regenerate .env from the `dev` env (default); direnv loads it
INFISICAL_ENV=prod make secrets-pull # override to pull the `prod` env locally if needed
```

Expected variables (stored in Infisical, generated into `.env` — there is no committed `.env.example`):

| Variable | Purpose |
|----------|---------|
| `CLOUDFLARE_API_TOKEN` | Cloudflare deploy (wrangler) + OpenTofu infra |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare account id |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | R2 S3 keys for the OpenTofu state backend (ADR 0008) |
| `PUBLIC_CF_BEACON_TOKEN` | Cloudflare Web Analytics beacon (public, build-time; not a secret) |
| `ANTHROPIC_API_KEY` | optional fallback for the i18n CLI (OAuth is the default) |

The same secrets feed CI: the deploy workflow migrates to fetching the **`prod`** secrets at runtime
via Infisical's GitHub Action over **OIDC** (no long-lived secrets in GitHub). See ADR 0009 and
`docs/playbook/secrets-infisical.md`.

**One exception** — the `release-tag` workflow needs a **`GH_PAT_TOKEN`** fine-grained PAT
(Contents:write, this repo only) to push `v*` tags so `deploy` triggers; there is no OIDC path to
push git tags as a user. It lives as a **GitHub Actions secret**, not in Infisical, and is
provisioned/rotated reproducibly with `make repo-settings-gh-pat-token-set` (stored via gh's native
masked prompt). `-status` checks it exists and, given the token
(`GH_PAT_TOKEN=<token> make repo-settings-gh-pat-token-status`), **verifies it can create tags**;
`-delete` removes the secret and opens the tokens page to revoke the PAT (GitHub has no API to delete
a user's own PAT). See ADR 0010.

## Governance

- **Every change goes through a Pull Request**; direct pushes to `main` are blocked by a local
  `pre-push` hook (`make init`). Server-side enforcement (ruleset) is enabled once the repo is public
  or on GitHub Pro — `make gh-bootstrap` provisions it automatically when available.
- **Conventional Commits** drive automated **semver tagging** (on push to `main`) and the generated
  **`CHANGELOG.md`** (on tag). See `.github/workflows/`.
- Spec-driven: new capabilities start as an **OpenSpec** change proposal under `openspec/`.

## License

Private project (not yet public). © Guillaume Mocquet.
