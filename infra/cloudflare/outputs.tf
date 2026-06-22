output "nameservers" {
  description = "Set these as the domain's nameservers at OVH to delegate DNS to Cloudflare."
  value       = cloudflare_zone.site.name_servers
}

output "pages_subdomain" {
  description = "The *.pages.dev URL of the Pages project (used as the CNAME target)."
  value       = local.pages_host
}

output "web_analytics_token" {
  description = "Set as the PUBLIC_CF_BEACON_TOKEN build variable (public; embedded in the page)."
  value       = cloudflare_web_analytics_site.site.site_token
}
