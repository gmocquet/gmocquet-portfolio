# Cloudflare infrastructure (OpenTofu)

Declares the Cloudflare resources behind the public site: the DNS **zone**, the **Pages** project,
its custom **domains** (apex + `www`), the routing **DNS records**, and the cookieless **Web
Analytics** site. OpenTofu version is pinned via `.opentofu-version` (tenv); the provider is pinned in
`versions.tf` with `.terraform.lock.hcl` committed.

> Static assets are **not** managed here — they are pushed to the Pages project by `wrangler`
> (`scripts/deploy.sh`, run from `deploy.yml`). This file provisions the platform; CI deploys the build.

## Prerequisites

1. A Cloudflare account (free) and your **Account ID**.
2. A Cloudflare **API token** with these scopes:
   - Account · **Cloudflare Pages** : Edit
   - Account · **Account Settings** : Read
   - Account · **Account Analytics** : Edit
   - Zone · **Zone** : Edit
   - Zone · **DNS** : Edit
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

Outputs:

- `nameservers` — set these as the domain's nameservers **at OVH** to delegate DNS to Cloudflare.
- `pages_subdomain` — the `*.pages.dev` URL the custom domains point to.
- `web_analytics_token` — set as the GitHub Actions **variable** `PUBLIC_CF_BEACON_TOKEN`
  (`gh variable set PUBLIC_CF_BEACON_TOKEN "$(tofu output -raw web_analytics_token)"`).

## State

Local state for the solo bootstrap (`*.tfstate` is gitignored — it can hold sensitive values).
**Follow-up (recommended before sharing operations):** move to a remote backend (HCP Terraform or a
Cloudflare R2 S3-compatible bucket) for shared, locked, durable state.

## Notes

- The one step that cannot be codified here is changing the registrar nameservers at **OVH** — do it
  once with the `nameservers` output, then wait for activation.
- After `apply`, the zone is pending until OVH points at the Cloudflare nameservers.
