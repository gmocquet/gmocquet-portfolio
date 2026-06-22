locals {
  # Canonical Pages host — the CNAME target to set for `www` at OVH.
  pages_host = "${var.project_name}.pages.dev"
}

# Pages project (Direct Upload — assets are pushed by wrangler from CI, no Git source here).
resource "cloudflare_pages_project" "site" {
  account_id        = var.account_id
  name              = var.project_name
  production_branch = var.production_branch
}

# Custom domain: `www` is served by Pages. DNS stays authoritative at OVH — a `www` CNAME to the
# Pages host (created at OVH) validates this domain. The apex redirects to `www` at OVH. We do NOT
# delegate the zone to Cloudflare, so email (MX/SPF) and DNSSEC are left untouched at OVH.
resource "cloudflare_pages_domain" "www" {
  account_id   = var.account_id
  project_name = cloudflare_pages_project.site.name
  name         = "www.${var.domain}"
}

# NOTE: Cloudflare Web Analytics (RUM) is intentionally not managed here. Creating a RUM site needs an
# account-analytics *edit* scope that Cloudflare does not expose to scoped API tokens (read-only only).
# The cookieless beacon stays in-code (Base.astro, gated by PUBLIC_CF_BEACON_TOKEN); provision the WA
# site once from the dashboard, then set PUBLIC_CF_BEACON_TOKEN to its token.
