# Architecture Decision Records (ADRs)

Each structural decision is captured here as a **numbered, immutable** record. Supersede a decision
with a new ADR rather than editing an old one. Format: Context → Decision → Consequences → Status.

## Index

- [0001 — Two self-contained ecosystems in a single repo](0001-two-ecosystem-monorepo.md)
- [0002 — Static Astro site on Cloudflare Pages](0002-astro-static-cloudflare-pages.md)
- [0003 — Content/presentation decoupling (YAML + Zod)](0003-content-presentation-decoupling.md)
- [0004 — Makefile + scripts/ as the single task runner](0004-makefile-scripts-task-runner.md)
- [0005 — IaC with OpenTofu; deploy via wrangler Direct Upload in CI](0005-iac-opentofu-cloudflare-deploy.md)
- [0006 — Keep DNS at OVH; serve `www` via Pages, redirect the apex](0006-keep-ovh-dns-www-via-pages.md)

## Adding an ADR

Copy the next number, write the four sections, and add it to the index above.
