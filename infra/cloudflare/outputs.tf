output "nameservers" {
  description = "Set these as the domain's nameservers at OVH to delegate DNS to Cloudflare."
  value       = cloudflare_zone.site.name_servers
}

output "pages_subdomain" {
  description = "The *.pages.dev URL of the Pages project (the CNAME target for apex + www)."
  value       = local.pages_host
}

output "dnssec_ds" {
  description = "Full DS record to add at the OVH registrar (Domain names → DNSSEC)."
  value       = cloudflare_zone_dnssec.site.ds
}

output "dnssec_fields" {
  description = "Individual DS/DNSKEY fields, in case the OVH form asks for them separately."
  value = {
    key_tag     = cloudflare_zone_dnssec.site.key_tag
    algorithm   = cloudflare_zone_dnssec.site.algorithm
    digest_type = cloudflare_zone_dnssec.site.digest_type
    digest      = cloudflare_zone_dnssec.site.digest
    flags       = cloudflare_zone_dnssec.site.flags
    public_key  = cloudflare_zone_dnssec.site.public_key
  }
}
