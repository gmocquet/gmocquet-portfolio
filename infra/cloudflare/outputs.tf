output "pages_subdomain" {
  description = "The *.pages.dev URL of the Pages project — the CNAME target to set for `www` at OVH."
  value       = local.pages_host
}
