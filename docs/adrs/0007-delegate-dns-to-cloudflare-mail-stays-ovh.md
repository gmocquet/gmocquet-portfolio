# 0007 — Delegate DNS to Cloudflare; keep mail at OVH (records replicated)

- **Status**: Accepted (2026-06-22) — supersedes ADR 0006.

## Context

ADR 0006 kept DNS at OVH and pointed only `www` at Pages, with the apex redirecting to `www`. That
works in HTTP, but **OVH does not support HTTPS on domain/DNS-level redirections** (confirmed by OVH:
"never supported https and never will" — the only OVH path is a paid hosting plan). So
`https://guillaumemocquet.com` (the bare apex) could not be served. DNS authority is indivisible on a
single zone (a split "web on Cloudflare / mail on OVH" needs Cloudflare's paid partial setup), so the
only free way to serve the apex over HTTPS is to make Cloudflare authoritative for the zone.

## Decision

**Delegate the zone to Cloudflare** (nameservers OVH → Cloudflare) and serve **apex + www directly over
HTTPS** via Pages (CNAME flattening at the apex, both proxied). `guillaumemocquet.com` is canonical;
`www` also serves (the HTML `<link rel="canonical">` points to the apex — no redirect rule needed).

**Mail stays entirely at OVH.** Only the DNS *records* move: the OVH `MX`, `SPF`, the two `DKIM`
CNAMEs, the `SRV` autodiscovery records and the mail-service CNAMEs (`imap`/`smtp`/… → `ssl0.ovh.net`)
are **replicated verbatim** into Cloudflare (DNS-only, never proxied). Delivery, mailboxes and IMAP/SMTP
are unchanged — Cloudflare is only the phone book.

**DNSSEC** is handled in order to avoid an outage: disable it at OVH (remove the DS), wait for the DS to
expire (~24 h), then switch the nameservers; optionally re-enable DNSSEC on Cloudflare afterwards.

All of this is in OpenTofu (`infra/cloudflare/`). State is committed to this (private, single-operator)
repo for now — no credentials are in it — and will move to a remote backend before going public.

## Consequences

- Apex + www both served over HTTPS; clean canonical domain.
- Email is untouched (records replicated; mailboxes stay at OVH).
- Cloudflare now fronts all DNS — full IaC, proxy/CDN/analytics available on the zone.
- The DNSSEC re-key requires a ~24 h disable window during the migration.
- A future mail-record change at OVH must be mirrored in `infra/cloudflare/` (the records now live here).
