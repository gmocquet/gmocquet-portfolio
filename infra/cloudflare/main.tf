locals {
  # Canonical Pages host the apex/www CNAMEs point to (CNAME flattening at the apex).
  pages_host = "${var.project_name}.pages.dev"

  # Mail records replicated verbatim from OVH — the mailboxes stay at OVH; Cloudflare is only the DNS.
  mx_records = {
    mx0 = { priority = 1, content = "mx0.mail.ovh.net" }
    mx1 = { priority = 5, content = "mx1.mail.ovh.net" }
    mx2 = { priority = 50, content = "mx2.mail.ovh.net" }
    mx3 = { priority = 100, content = "mx3.mail.ovh.net" }
  }

  # Mail/service CNAMEs — DNS-only (never proxied): they point at OVH's mail/ftp/DKIM infrastructure.
  service_cnames = {
    "autoconfig"                        = "mailconfig.ovh.net"
    "ftp"                               = "ftp.cluster017.ovh.net"
    "imap"                              = "ssl0.ovh.net"
    "mail"                              = "ssl0.ovh.net"
    "pop3"                              = "ssl0.ovh.net"
    "smtp"                              = "ssl0.ovh.net"
    "ovhmo2786047-selector1._domainkey" = "ovhmo2786047-selector1._domainkey.1710504.gs.dkim.mail.ovh.net"
    "ovhmo2786047-selector2._domainkey" = "ovhmo2786047-selector2._domainkey.1710503.gs.dkim.mail.ovh.net"
  }

  # Mail-client autodiscovery (SRV) — priority/weight 0, as exported from OVH.
  srv_records = {
    autodiscover = { service = "_autodiscover._tcp", port = 443, target = "mailconfig.ovh.net" }
    imaps        = { service = "_imaps._tcp", port = 993, target = "ssl0.ovh.net" }
    submission   = { service = "_submission._tcp", port = 465, target = "ssl0.ovh.net" }
  }
}

# DNS zone — Cloudflare becomes authoritative once OVH delegates the nameservers (see README).
resource "cloudflare_zone" "site" {
  account = { id = var.account_id }
  name    = var.domain
  type    = "full"
}

# Pages project (Direct Upload — assets are pushed by wrangler from CI).
resource "cloudflare_pages_project" "site" {
  account_id        = var.account_id
  name              = var.project_name
  production_branch = var.production_branch
}

# --- Website: apex + www served by Pages, HTTPS via CNAME flattening (proxied) ---
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

# --- Email (replicated from OVH; mailboxes and delivery stay at OVH) ---
resource "cloudflare_dns_record" "mx" {
  for_each = local.mx_records
  zone_id  = cloudflare_zone.site.id
  name     = var.domain
  type     = "MX"
  content  = each.value.content
  priority = each.value.priority
  ttl      = 3600
}

resource "cloudflare_dns_record" "spf" {
  zone_id = cloudflare_zone.site.id
  name    = var.domain
  type    = "TXT"
  content = "v=spf1 include:mx.ovh.com ~all"
  ttl     = 600
}

# DMARC — authored here (NOT replicated from OVH). Enforcement at quarantine; aggregate reports go to
# postmaster@ (same domain, so no _report._dmarc cross-domain authorization is needed). OVH DKIM is
# domain-aligned, so legitimate OVH mail passes DMARC. See README "State"/mail section.
resource "cloudflare_dns_record" "dmarc" {
  zone_id = cloudflare_zone.site.id
  name    = "_dmarc.${var.domain}"
  type    = "TXT"
  content = "v=DMARC1; p=quarantine; rua=mailto:postmaster@${var.domain}; adkim=r; aspf=r; pct=100; sp=quarantine"
  ttl     = 3600
}

resource "cloudflare_dns_record" "service_cname" {
  for_each = local.service_cnames
  zone_id  = cloudflare_zone.site.id
  name     = "${each.key}.${var.domain}"
  type     = "CNAME"
  content  = each.value
  proxied  = false
  ttl      = 3600
}

resource "cloudflare_dns_record" "srv" {
  for_each = local.srv_records
  zone_id  = cloudflare_zone.site.id
  name     = "${each.value.service}.${var.domain}"
  type     = "SRV"
  ttl      = 3600
  data = {
    priority = 0
    weight   = 0
    port     = each.value.port
    target   = each.value.target
  }
}

# DNSSEC — enable signing on Cloudflare; the resulting DS record must be added at the OVH registrar
# (Domain names → DNSSEC) to re-establish the chain of trust. See the `dnssec_*` outputs.
resource "cloudflare_zone_dnssec" "site" {
  zone_id = cloudflare_zone.site.id
  status  = "active"
}
