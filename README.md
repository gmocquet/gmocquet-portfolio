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

## Governance

- **Every change goes through a Pull Request**; `main` is protected (PR-only), checks required.
- **Conventional Commits** drive automated **semver tagging** (on push to `main`) and the generated
  **`CHANGELOG.md`** (on tag). See `.github/workflows/`.
- Spec-driven: new capabilities start as an **OpenSpec** change proposal under `openspec/`.

## License

Private project (not yet public). © Guillaume Mocquet.
