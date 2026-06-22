# Agentic Coding — build log

Chronological journal of how this project is built with a piloted team of expert agents. Doubles as a
generalizable draft for LinkedIn/blog articles. Most recent entry **last**.

## 2026-06-20 — M0: bootstrap & governance

- Approved an incremental plan (Lot 1 = public showcase site) after a deep requirements pass.
- Chose a two-ecosystem repo (`frontend/` TS/React/Astro, `backend/` Python skeleton), content as
  YAML decoupled from presentation, EM-first positioning, Cloudflare Pages hosting.
- Scaffolded root governance & tooling: `README.md` + `CLAUDE.md` (`@README.md` import),
  `.claude/settings.json`, `Makefile` (one-liner task runner) + `scripts/` (doctor, init, lint, test,
  deploy, github-bootstrap), `.envrc` (direnv), root `.gitignore`, ADRs (0001–0004) and playbooks.
- Recorded environment gaps surfaced by `make doctor` (uv, gh, pre-commit, direnv, wrangler, …) — to
  be installed per `CONTRIBUTING.md`.

## 2026-06-21 — M1: foundations (both ecosystems)

- **backend/** (uv, Python 3.14.6): FastAPI/Pydantic/uvicorn declared (skeleton, no business logic);
  dev deps ruff/pytest/pre-commit; exact pins + `uv.lock`; ruff config; README/CONTRIBUTING/.gitignore.
- **frontend/** (npm workspaces): Astro 6.4.8 static + React 19 islands + Tailwind v4 (`@tailwindcss/vite`)
  with `@theme` design tokens; `@gmocquet/ui` library (shadcn-style `Button` on cva/clsx/tailwind-merge),
  consumed via its public API as a hydrated island; Biome; exact pins via `.npmrc` + `package-lock.json`.
  `pre-commit` managed as a uv dev dep (Python) per ecosystem, orchestrating Biome/ruff.
- Wired `scripts/lint.sh` to run pre-commit via `uv run --project <eco>`; each hook runs from its own
  ecosystem dir (correct tool root). **`make build` / `make lint` / `make doctor` all green.**

## 2026-06-22 — Post-M3 refinements (visual-pass TODO)

A visual pass on the M3 site produced four refinements, delivered as focused PRs off `main`:

- **`/tags` skill matcher (this PR).** A discovery page where a visitor selects skill tags and sees
  whether they're in my toolkit and **where** I've applied them. Built as a React island
  (`@gmocquet/ui` `TagMatcher`) fed by content props (content-agnostic). The tag catalog merges the
  curated `profile.skills` groups with a "Tech stack" group built from every experience/project
  `stack`; selecting tags ranks the matching experiences/projects by relevance (pure, unit-tested
  `buildTagGroups`/`rankEntries`), with deep links to `/projects/<id>` and `/about#exp-<id>` and a
  shareable `?tags=` URL. Searching a skill that isn't in the catalog is the explicit "I don't have
  it" answer.
  - *Direction change:* a full-text search via **Pagefind** was prototyped first; we dropped it in
    favor of this tag-based matcher — the visitor's real question is "do you have skill X?", not
    "find the word X on the site".
- **Inline video embeds (PR #7).** `@gmocquet/ui` `VideoEmbed` (responsive 16:9, lazy, privacy-friendly
  `youtube-nocookie` / Vimeo `dnt`) + pure `toEmbedUrl` helper; project pages embed video media inline.
- **Home (PR #8).** De-emphasized the raw role count in favor of a scale-impact stat; "Selected work"
  stays the featured subset with a counted `All projects (N)` link.
- Introduced **vitest** (frontend) for the pure helpers; `make test` now runs the frontend suite.
- Pre-publish: removed the email (and self website link) from the site — contacts are now LinkedIn +
  GitHub only (#10).

## 2026-06-22 — M5: deploy to Cloudflare Pages (full IaC)

- **OpenTofu** (`infra/cloudflare/`, provider `cloudflare` 5.21.0 pinned, lock committed, binary pinned
  via `tenv`) provisions the platform per ADR 0002/0005: DNS **zone**, **Pages project** (Direct
  Upload), custom **domains** (apex + `www`), routing **DNS records**, and a cookieless **Web
  Analytics** site. `tofu validate` green. State local for the bootstrap (gitignored); remote backend
  is the planned hardening step.
- **CI deploy** (`.github/workflows/deploy.yml`): on push to `main`, build + `wrangler` Direct Upload
  via the shared `make deploy` target (pinned Node, SHA-pinned actions). Platform (OpenTofu) and
  artifact (wrangler) are deliberately separated.
- **Web Analytics** beacon injected in-code in `Base.astro`, gated by the public build variable
  `PUBLIC_CF_BEACON_TOKEN` (an OpenTofu output) — absent locally, present once configured.
- The only non-codified step is the OVH → Cloudflare **nameserver delegation** at the registrar.
