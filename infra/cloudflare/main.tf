locals {
  # Canonical Pages host the custom domains point to (CNAME target).
  pages_host = "${var.project_name}.pages.dev"
}

# DNS zone — Cloudflare returns the nameservers to set at the registrar (OVH) to delegate DNS.
resource "cloudflare_zone" "site" {
  account = { id = var.account_id }
  name    = var.domain
  type    = "full"
}

# Pages project (Direct Upload — assets are pushed by wrangler from CI, no Git source here).
resource "cloudflare_pages_project" "site" {
  account_id        = var.account_id
  name              = var.project_name
  production_branch = var.production_branch
}

# Attach the custom domains (apex + www) to the Pages project.
resource "cloudflare_pages_domain" "apex" {
  account_id   = var.account_id
  project_name = cloudflare_pages_project.site.name
  name         = var.domain
}

resource "cloudflare_pages_domain" "www" {
  account_id   = var.account_id
  project_name = cloudflare_pages_project.site.name
  name         = "www.${var.domain}"
}

# DNS records routing apex + www to the Pages host (proxied; CNAME flattening at the apex).
resource "cloudflare_dns_record" "apex" {
  zone_id = cloudflare_zone.site.id
  name    = var.domain
  type    = "CNAME"
  content = local.pages_host
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "www" {
  zone_id = cloudflare_zone.site.id
  name    = "www.${var.domain}"
  type    = "CNAME"
  content = local.pages_host
  proxied = true
  ttl     = 1
}

# Cookieless Web Analytics — the beacon is injected in-code (auto_install = false).
resource "cloudflare_web_analytics_site" "site" {
  account_id   = var.account_id
  host         = var.domain
  auto_install = false
}
