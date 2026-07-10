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
- **DNSSEC handled by ordering:** disabled at OVH → waited for the DS to expire (verified gone from the
  registry and all major resolvers) → switched the nameservers. Zero email downtime; zone went active,
  apex + www certs issued. Then **re-enabled DNSSEC on Cloudflare** (`cloudflare_zone_dnssec`) — the new
  DS (key tag 2371, algo 13) is added back at the OVH registrar to re-form the chain of trust.
- TF state committed to the (private, single-operator) repo as an interim — no credentials in it; remote
  backend is the planned hardening.

## 2026-06-24 — Secure the OpenTofu state in Cloudflare R2

- Moved `infra/cloudflare/terraform.tfstate` out of git into a **private Cloudflare R2 bucket**
  (`gmocquet-portfolio-tfstate`) via the OpenTofu `s3` backend (`backend.tf`): `region = "auto"`, the
  account R2 S3 endpoint, `use_path_style`, `use_lockfile`, and the AWS-only preflight skips R2 needs.
  Same vendor as the infra, permanent free tier; **no passphrase** (recoverability > zero-trust — the
  state holds no secrets, only resource IDs + public DNS records). See ADR 0008.
- `tofu init -migrate-state` copied the local state to R2 losslessly; `tofu state list` reads the 23
  resources from R2 and `use_lockfile` works. Removed the state from the working tree and re-ignored
  `*.tfstate`; the historical blob is removed from git history in a follow-up rewrite (out of PR — a
  history rewrite can't go through one).
- Flagged for a separate `fix(infra)`: a pre-existing SRV-record drift (`priority = 0 -> null` on the 3
  `_tcp` SRV records) surfaced by `tofu plan` — a Cloudflare provider v5 normalization, independent of
  the state move.

## 2026-06-25 — Email authentication: publish DMARC (p=quarantine)

- A DNS audit of `guillaumemocquet.com` came back healthy except for **one gap: no DMARC record**
  (the domain was spoofable, with zero reporting visibility). MX/SPF/DKIM/SRV, DNSSEC (`ad` validated)
  and HTTPS on apex + www were all green.
- Added `cloudflare_dns_record.dmarc` (`infra/cloudflare/main.tf`) — `_dmarc` TXT, **authored here**
  (not replicated from OVH): `v=DMARC1; p=quarantine; rua=mailto:postmaster@…; adkim=r; aspf=r;
  pct=100; sp=quarantine`. OVH's DKIM is domain-aligned, so legitimate mail passes — enforcement is
  low-risk. `rua` is same-domain (`postmaster@`), so no `_report._dmarc` cross-domain authorization is
  needed.
- Applied in isolation with `tofu apply -target=cloudflare_dns_record.dmarc` to avoid pulling the
  pre-existing SRV drift into this change (still parked for its own `fix(infra)`).
- Parked follow-ups: SPF `~all` → `-all`; ramp DMARC `quarantine` → `reject` after clean `rua` reports;
  BIMI only with a VMC (not worth it for a portfolio).

## 2026-06-25 — Secrets in Infisical (single source of truth)

- Adopted **Infisical Cloud (free tier)** as the single source of truth for application secrets
  (Cloudflare token/account, R2 S3 keys, beacon token, optional Anthropic key) — project
  `gmocquet-portfolio-secrets`, envs `dev` (local) + `prod` (CI). Chosen over Doppler (proprietary),
  Bitwarden (two products) and HCP Vault Secrets (EOL 2026-07-01); open source → self-host escape
  hatch. See ADR 0009.
- **Local**: `make secrets-pull` (`scripts/secrets-pull.sh`) regenerates the gitignored, ephemeral
  `.env` from the `dev` env via `infisical export` (override `INFISICAL_ENV=prod`); direnv loads it
  as before — only the file's *source* moves to Infisical. Repo linked via the committed
  `.infisical.json` (ids only, no secret). First Bash unit tests land with this
  (`scripts/tests/*.bats`, stubbed CLI); `make doctor` gains an Infisical presence/auth check.
- **CI (follow-up PR)**: the deploy workflow fetches the same secrets at runtime via Infisical's
  GitHub Action over **OIDC** (`id-token: write`), dropping the long-lived `CLOUDFLARE_*` GitHub
  Secrets/Variables. No long-lived root credential anywhere (local = OAuth login, CI = OIDC).

## 2026-06-25 — Silence the perpetual SRV priority drift

- Since the PR #14 apply, every `tofu plan` showed `priority = 0 -> null` on the 3 `_tcp` SRV records:
  the Cloudflare API returns a **top-level `priority = 0`** for SRV (the real priority lives in `data`,
  already `0`), and our config never sets the top-level field — so it read back as a permanent diff that
  an apply couldn't settle (the API re-returns `0` on each refresh).
- Fixed with `lifecycle { ignore_changes = [priority] }` on `cloudflare_dns_record.srv`
  (`infra/cloudflare/main.tf`) — **config-only, no DNS write**. `tofu plan` now reports **No changes**,
  so routine plans/applies no longer need `-target` to dodge this noise. Functionally a no-op (the SRV
  records were always correct); it just reconciles the IaC with what the provider reports.

## 2026-06-25 — Harden SPF to hardfail (`-all`)

- Tightened the SPF record from softfail to **hardfail**: `v=spf1 include:mx.ovh.com ~all` →
  `… -all` (`cloudflare_dns_record.spf`). Unauthorized senders (anything not OVH) are now declared as
  forgeries to be **rejected**, not merely flagged.
- DMARC (`p=quarantine`) already does the heavy lifting via alignment; `-all` is defense in depth and
  the unambiguous posture. Done **before** the ~2-week DMARC-report window as a deliberate call — OVH is
  the sole sender for this personal domain. Trivially reversible (`-all` → `~all` + apply) if a report
  ever surfaces a legitimate non-OVH sender.
- Unlike the SRV fix, this is a real DNS change → applied (`tofu apply`) and verified live with `dig`.

## 2026-06-25 — Release-driven deploy (deploy on `v*` tags)

- Moved `deploy` from "on every push to `main`" to **on every `v*` release tag** — deploys now map to
  the semantic version produced by `release-tag` (bootstrap `v0.0.1`; patch by default, minor on
  `feat`, major on breaking). `release-tag` keeps creating the tag with the default `GITHUB_TOKEN`.

## 2026-07-10 — Fix the deploy trigger (release tags via a fine-grained PAT)

- Symptom: `v0.0.8` (the white-paper refresh) was tagged by `release-tag` but **`deploy` never ran**;
  the live site stayed stale. Root cause: GitHub does **not** start workflow runs from events created
  by the automatic `GITHUB_TOKEN` (anti-recursion), so a tag it pushes can never trigger
  `deploy.yml`'s `push: tags: v*`. No deploy had run since the tag-trigger switch (PR #24).
- Fix: `release-tag.yml` now pushes the tag with a **fine-grained PAT** (`secrets.GH_PAT_TOKEN`,
  Contents:write) — a real user identity, so the push triggers `deploy`. `deploy.yml` is unchanged.
- Tooling: ported `repo-settings-token-*` from `gmocquet/neo`, renamed to
  **`repo-settings-gh-pat-token-*`** and adapted to this repo (Makefile one-liners →
  `scripts/repo-settings-gh-pat-token.sh`, bats-tested). `-set` opens the pre-filled PAT page and
  stores the token via `gh secret set`; `-status` / `-delete` manage it. The PAT lives as a GitHub
  Actions secret — a documented, narrow exception to the Infisical source-of-truth (ADR 0009), since
  there is no OIDC path to push git tags as a user. See ADR 0010.
