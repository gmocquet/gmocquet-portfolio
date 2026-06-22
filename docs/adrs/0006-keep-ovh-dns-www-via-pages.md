# 0006 — Keep DNS at OVH; serve `www` via Pages, redirect the apex

- **Status**: Accepted (2026-06-22) — supersedes the DNS-delegation part of ADR 0002/0005.

## Context

ADR 0002/0005 planned to delegate the zone OVH → Cloudflare. But `guillaumemocquet.com` has **active
DNSSEC** and a **production mailbox** (`contact@guillaumemocquet.com`) on OVH (MX `*.mail.ovh.net`,
SPF). Switching nameservers would make Cloudflare authoritative for the whole zone — and Cloudflare did
**not** import the MX/SPF records — so a naive switch would break email, and the DNSSEC chain (DS still
pointing at OVH keys) would fail validation (SERVFAIL = full outage). A safe delegation is possible but
requires replicating all mail records and a ~24 h DNSSEC-disable wait.

## Decision

**Keep OVH authoritative for DNS** (email + DNSSEC untouched). Point only the website at Cloudflare Pages:

- `www.guillaumemocquet.com` → **CNAME** → `guillaumemocquet.pages.dev` (record at OVH); added as a
  Pages **custom domain** (validated via that CNAME; Cloudflare auto-provisions TLS). `www` is the
  **canonical** host (`astro.config.mjs` `site`).
- Apex `guillaumemocquet.com` → **301 redirect** → `https://www.guillaumemocquet.com` (OVH redirection;
  the apex A record it adds coexists with the MX).

OpenTofu therefore manages only the Pages project + the `www` custom domain — no zone, no DNS records.

## Consequences

- **Zero risk to email and DNSSEC** — no nameserver change, no DNSSEC dance.
- The apex doesn't serve directly (it redirects); `www` is primary. Acceptable for a portfolio.
- No Cloudflare proxy/CDN on the apex and DNS is not fully IaC (it lives at OVH). A future full
  delegation (ADR 0002 path), done with mail records pre-replicated + DNSSEC handled, remains an option.
- Cloudflare Web Analytics can't be provisioned by a scoped token (no edit scope) → created from the
  dashboard; the in-code beacon stays.
