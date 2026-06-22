# 0005 — IaC with OpenTofu; deploy via wrangler Direct Upload in CI

- **Status**: Accepted (2026-06-22)

## Context

ADR 0002 chose Cloudflare Pages hosting with the domain `guillaumemocquet.com` (DNS delegated
OVH → Cloudflare) and cookieless Web Analytics. The project mandates **100% IaC, no ClickOps** and
reproducible builds. We need to provision the Cloudflare platform and ship the static build to it.

## Decision

Provision all Cloudflare resources with **OpenTofu** (`infra/cloudflare/`, provider
`cloudflare/cloudflare` pinned, lock committed, binary pinned via `tenv`/`.opentofu-version`):
the DNS **zone**, the **Pages project** (Direct Upload), its custom **domains** (apex + `www`), the
routing **DNS records**, and the **Web Analytics** site.

Separate **platform** from **artifact**: OpenTofu owns the platform; the static build is pushed by
**wrangler Direct Upload** (`scripts/deploy.sh`) from a **GitHub Actions** workflow (`deploy.yml`) on
every push to `main`. Local and CI run the same `make deploy` target. The Web Analytics beacon is
injected **in-code** in `Base.astro`, gated by the public build variable `PUBLIC_CF_BEACON_TOKEN`
(the token is an OpenTofu output).

State is local for the solo bootstrap (gitignored); a remote backend (HCP Terraform or Cloudflare R2)
is the planned hardening step.

## Consequences

- The platform is reproducible and reviewable; the only manual step is the registrar nameserver change
  at OVH (outside Cloudflare's control).
- Build and deploy are one pipeline; the same command works locally and in CI.
- Direct Upload keeps the build in our CI (pinned Node, our tooling) rather than Cloudflare's builder.
- Local state must be migrated to a remote backend before operations are shared across machines.
