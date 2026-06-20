# Change: add-public-portfolio-site

## Why

Lot 1 delivers the **public showcase site** for `guillaumemocquet.com`: an EM-first portfolio
(Engineering Manager — Data/AI · Platform & DevEx, backed by 5+ years as Staff Data Engineer). It
must be responsive, very fast, JAMstack/headless, hosted on Cloudflare free tier, and exemplary as an
architecture showcase + reusable base for future frontend/backend SaaS projects.

## What Changes

- **Capability `public-site`**: bilingual (EN source, FR generated) static portfolio with pages
  Home, About, Projects (+ detail), Contact, built with Astro 6 (static) + React islands, Tailwind
  v4, shadcn/ui + Magic UI (disciplined), dark-first "luxe" design tokens.
- **Capability `content-model`**: content stored as human-friendly YAML under `frontend/content/`,
  validated by Zod (fail-fast); content-agnostic components driven by a block registry; self-service
  editing (add/remove an entry = edit one YAML file).
- **Capability `i18n-translation`**: idempotent EN→FR translation CLI (Claude via OAuth by default),
  regenerating FR when the EN source hash changes (manual FR edits overwritten on EN change).
- **Capability `delivery`**: GitHub Actions deploy to Cloudflare Pages, DNS delegation OVH→Cloudflare,
  Cloudflare Web Analytics, semver tagging + generated CHANGELOG via Conventional Commits.

Out of scope (later lots): private area (token auth), tracking, blog + admin, Python backend runtime.

## Impact

- New ecosystems `frontend/` (built) and `backend/` (skeleton). New tooling (Makefile, scripts/,
  doctor, CI workflows). New domain online at `guillaumemocquet.com`.
- No user data, no auth, no server runtime in Lot 1 — fully static.
