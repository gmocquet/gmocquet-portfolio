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

Hosting is **Cloudflare Pages** with the domain `guillaumemocquet.com` (see ADR 0002/0005). Two parts:

- **Platform as IaC** — `infra/cloudflare/` (OpenTofu) provisions the DNS zone, the Pages project,
  the custom domains (apex + `www`), the DNS records and the cookieless Web Analytics site. See
  `infra/cloudflare/README.md` for the apply runbook and the exact API-token scopes. The one manual
  step is delegating the domain's nameservers **OVH → Cloudflare** (registrar side).
- **Continuous deploy** — `.github/workflows/deploy.yml` runs `make deploy` (build + `wrangler` Direct
  Upload) on every push to `main`. It needs the `CLOUDFLARE_API_TOKEN` / `CLOUDFLARE_ACCOUNT_ID`
  secrets and the `PUBLIC_CF_BEACON_TOKEN` variable (the Web Analytics token, an OpenTofu output).
  `make deploy` also works locally (see `.env.example`).

## Governance

- **Every change goes through a Pull Request**; direct pushes to `main` are blocked by a local
  `pre-push` hook (`make init`). Server-side enforcement (ruleset) is enabled once the repo is public
  or on GitHub Pro — `make gh-bootstrap` provisions it automatically when available.
- **Conventional Commits** drive automated **semver tagging** (on push to `main`) and the generated
  **`CHANGELOG.md`** (on tag). See `.github/workflows/`.
- Spec-driven: new capabilities start as an **OpenSpec** change proposal under `openspec/`.

## License

Private project (not yet public). © Guillaume Mocquet.
