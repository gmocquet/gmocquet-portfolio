# Cloudflare infrastructure (OpenTofu)

Declares the Cloudflare resources behind the public site: the **Pages** project and its **`www`
custom domain**. OpenTofu version is pinned via `.opentofu-version` (tenv); the provider is pinned in
`versions.tf` with `.terraform.lock.hcl` committed.

> **DNS stays at OVH.** We do **not** delegate the zone to Cloudflare — to leave the email (OVH MX/SPF)
> and DNSSEC untouched (see ADR 0006). Only `www` is pointed at Pages via a CNAME at OVH; the apex
> redirects to `www`. Static assets are pushed to the Pages project by `wrangler`
> (`scripts/deploy.sh`, run from `deploy.yml`).

## Prerequisites

1. A Cloudflare account (free) and your **Account ID**.
2. A Cloudflare **API token** with: Account · *Cloudflare Pages* : Edit, Account · *Account Settings* : Read.
   *(Zone/DNS scopes are no longer needed since the zone isn't on Cloudflare.)*
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

Output: `pages_subdomain` — the `*.pages.dev` host to use as the **CNAME target for `www`** at OVH.

## DNS at OVH (manual, one-time — no nameserver change)

1. **CNAME** `www` → `guillaumemocquet.pages.dev.` (DNS-only). This validates the `www` Pages custom
   domain and routes `www` to the site (Cloudflare provisions the TLS cert automatically).
2. **Apex redirect** `guillaumemocquet.com` → `https://www.guillaumemocquet.com` (301), via OVH's
   domain redirection. The redirect adds an A record at the apex, which coexists with the MX (email).
3. Nothing else changes — **MX, SPF and DNSSEC stay exactly as they are**.

## Web Analytics

Not managed here: creating a Cloudflare Web Analytics (RUM) site needs an account-analytics *edit*
scope that Cloudflare does not expose to scoped API tokens. Provision the WA site once from the
dashboard, then set its token as the `PUBLIC_CF_BEACON_TOKEN` build variable — the cookieless beacon
is already wired in-code (`Base.astro`).

## State

Local state for the solo bootstrap (`*.tfstate` is gitignored). **Follow-up:** move to a remote backend
(HCP Terraform or a Cloudflare R2 S3-compatible bucket) for shared, locked, durable state.
