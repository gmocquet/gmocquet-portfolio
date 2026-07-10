# Architecture Decision Records (ADRs)

Each structural decision is captured here as a **numbered, immutable** record. Supersede a decision
with a new ADR rather than editing an old one. Format: Context → Decision → Consequences → Status.

## Index

- [0001 — Two self-contained ecosystems in a single repo](0001-two-ecosystem-monorepo.md)
- [0002 — Static Astro site on Cloudflare Pages](0002-astro-static-cloudflare-pages.md)
- [0003 — Content/presentation decoupling (YAML + Zod)](0003-content-presentation-decoupling.md)
- [0004 — Makefile + scripts/ as the single task runner](0004-makefile-scripts-task-runner.md)
- [0005 — IaC with OpenTofu; deploy via wrangler Direct Upload in CI](0005-iac-opentofu-cloudflare-deploy.md)
- [0006 — Keep DNS at OVH; serve `www` via Pages, redirect the apex](0006-keep-ovh-dns-www-via-pages.md) — *superseded by 0007*
- [0007 — Delegate DNS to Cloudflare; keep mail at OVH (records replicated)](0007-delegate-dns-to-cloudflare-mail-stays-ovh.md)
- [0008 — Remote OpenTofu state in Cloudflare R2 (private, no passphrase)](0008-remote-state-cloudflare-r2.md)
- [0009 — Application secrets in Infisical (single source of truth; .env generated, CI via OIDC)](0009-secrets-management-infisical.md)
- [0010 — Release tags pushed with a fine-grained PAT (so `deploy` triggers)](0010-repo-settings-gh-pat-token.md)

## Adding an ADR

Copy the next number, write the four sections, and add it to the index above.
