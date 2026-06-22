output "nameservers" {
  description = "Set these as the domain's nameservers at OVH to delegate DNS to Cloudflare."
  value       = cloudflare_zone.site.name_servers
}

output "pages_subdomain" {
  description = "The *.pages.dev URL of the Pages project (the CNAME target for apex + www)."
  value       = local.pages_host
}
