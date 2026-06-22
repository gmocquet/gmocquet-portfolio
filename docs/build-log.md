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
  `PUBLIC_CF_BEACON_TOKEN` — absent locally, present once configured.
- **Applied & went live:** `tofu apply` created the Pages project; a first `wrangler` deploy put the
  site live on `guillaumemocquet.pages.dev` immediately.
- **DNS pivot (ADR 0006).** The domain carries **active DNSSEC** and a **production OVH mailbox**;
  Cloudflare hadn't imported the MX/SPF, so an OVH → Cloudflare nameserver switch would have broken
  email and the DNSSEC chain (SERVFAIL). Chose to **keep DNS at OVH** and point only `www` at Pages
  (CNAME), apex → 301 → `www`. Reworked the IaC down to the Pages project + `www` custom domain
  (destroyed the zone/records); email and DNSSEC are left fully intact.
- **Web Analytics deferred:** creating a RUM site needs an account-analytics *edit* scope Cloudflare
  doesn't expose to scoped tokens → provision it from the dashboard later; the in-code beacon stays.

## 2026-06-22 — DNS migration to Cloudflare, mail kept at OVH (ADR 0007)

- The Option-B apex redirect (ADR 0006) only worked in HTTP: **OVH doesn't support HTTPS on DNS-level
  redirections** (their own answer: "never has, never will" — the only path is a paid hosting plan). And
  DNS authority is indivisible — "web on Cloudflare, mail on OVH" as separate authorities is a paid
  Cloudflare partial setup. So to serve `https://guillaumemocquet.com`, the zone must be on Cloudflare.
- Key insight communicated to the user: **moving DNS ≠ moving mail.** Delegated the zone to Cloudflare
  but **replicated every OVH mail record** (4× MX, SPF, 2× DKIM CNAME, 3× SRV, the `imap/smtp/…` service
  CNAMEs) verbatim as DNS-only records — mailboxes and delivery stay 100% at OVH.
- IaC re-expanded (`infra/cloudflare/`): zone + apex/www CNAMEs (proxied, flattening → HTTPS on both) +
  all mail records via `for_each`. Verified by querying Cloudflare's nameservers directly **before**
  switching: MX/SPF/DKIM/SRV all served correctly. Canonical is the apex (`www` also serves; canonical
  tag points to apex — no redirect rule).
- **DNSSEC handled by ordering:** disable at OVH → wait ~24 h for the DS to expire → switch nameservers
  → (optional) re-enable on Cloudflare. Zero email downtime.
- TF state committed to the (private, single-operator) repo as an interim — no credentials in it; remote
  backend is the planned hardening.
