# Cloudflare infrastructure (OpenTofu)

Declares the Cloudflare resources behind the public site: the DNS **zone**, the **Pages** project, its
custom **domains** (apex + `www`), the website **DNS records** (apex + www → Pages), the **mail
DNS records replicated from OVH**, and a **DMARC policy** record authored here. OpenTofu version is
pinned via `.opentofu-version` (tenv); the provider is pinned in `versions.tf` with
`.terraform.lock.hcl` committed.

> **DNS is delegated to Cloudflare; mail stays at OVH** (see ADR 0007). The apex + `www` are served
> directly over HTTPS by Pages (CNAME flattening). The OVH `MX`/`SPF`/`DKIM`/`SRV`/mail-service records
> are replicated here verbatim (DNS-only, never proxied) so mail delivery and mailboxes are unchanged —
> Cloudflare is only the DNS. **DMARC** (`_dmarc`) is the exception: it is **authored here** (not from
> OVH) at `p=quarantine`, with aggregate reports (`rua`) sent to `postmaster@guillaumemocquet.com`
> (same domain → no cross-domain authorization record needed); OVH's domain-aligned DKIM lets
> legitimate mail pass. Static assets are pushed to Pages by `wrangler` (`scripts/deploy.sh`).

## Prerequisites

1. A Cloudflare account (free) and your **Account ID**.
2. A Cloudflare **API token** with: Account · *Cloudflare Pages* : Edit, Account · *Account Settings* : Read,
   Zone · *Zone* : Edit, Zone · *DNS* : Edit, with **Zone Resources = All zones** (the zone is created here).
3. `tenv` installed (it installs the pinned OpenTofu on first run: `tenv opentofu install`).

## Apply

```bash
cd infra/cloudflare
export CLOUDFLARE_API_TOKEN=…           # never commit this
cp terraform.tfvars.example terraform.tfvars   # set account_id (or use TF_VAR_account_id)

tofu init
tofu plan
tofu apply
```

Output: `nameservers` — set these at OVH to delegate DNS to Cloudflare.

## Migration runbook (mail-safe, no downtime — order matters because of DNSSEC)

1. **Apply** (above) → the zone is created **pending** with every record pre-populated (web **and** mail).
   Verify Cloudflare already serves the mail records before switching:
   `dig MX guillaumemocquet.com @<one-of-the-nameservers>` → the OVH MX.
2. **OVH — disable DNSSEC** ("Délégation sécurisée" → off). This removes the DS from the `.com` registry.
3. **Wait ~24 h** — until `dig DS guillaumemocquet.com +short` returns nothing (old DS expired from
   caches). **Do not switch nameservers before this**, or DNSSEC validation fails (SERVFAIL outage).
4. **OVH — switch the nameservers** to the `nameservers` output. Mail keeps working (same MX served by
   Cloudflare); apex + www serve the site over HTTPS.
5. **Verify**: `dig NS` = Cloudflare; `dig MX` = the OVH MX; send/receive a test email; load both URLs.
6. **(Optional) re-enable DNSSEC** on Cloudflare and add the new DS at OVH.

## State

The state is stored **remotely in a private Cloudflare R2 bucket** (`gmocquet-portfolio-tfstate`, object
`cloudflare/terraform.tfstate`) via the `s3` backend in `backend.tf` — out of git (see ADR 0008). It holds
**no credentials** (the provider token comes from the environment), only Cloudflare resource IDs and public
DNS records; it is kept private and unencrypted by choice (recoverability > zero-trust).

**Credentials** — the backend reads the standard AWS env vars `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`,
set to an **R2 API token** (R2 → *Manage R2 API Tokens* → Object Read & Write, scoped to the bucket). Put
them in `.env` (gitignored, direnv) — never commit them.

**Init / migrate** — `direnv exec . tofu -chdir=infra/cloudflare init` (first time from a local state, add
`-migrate-state`). Verify with `tofu state list` (reads from R2).

**Recovery** — R2 is durable and the bucket is private, but R2 has **no object versioning**: before any
risky change, keep an off-git copy with `tofu state pull > tfstate-backup-<date>.json`. Last resort, the
infra is fully reconstructable — re-`import` the live Cloudflare resources into a fresh state (the `.tf`
files are the source of truth).

## Web Analytics

Not managed here: creating a Cloudflare Web Analytics (RUM) site needs an account-analytics *edit* scope
Cloudflare does not expose to scoped tokens. Provision it once from the dashboard, then set its token as
the `PUBLIC_CF_BEACON_TOKEN` build variable — the cookieless beacon is already wired in `Base.astro`.
