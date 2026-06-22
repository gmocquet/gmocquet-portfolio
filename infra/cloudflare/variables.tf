variable "account_id" {
  type        = string
  description = "Cloudflare account ID that owns the zone, Pages project and analytics site."
}

variable "domain" {
  type        = string
  description = "Apex domain served by the site."
  default     = "guillaumemocquet.com"
}

variable "project_name" {
  type        = string
  description = "Cloudflare Pages project name (also the *.pages.dev subdomain)."
  default     = "guillaumemocquet"
}

variable "production_branch" {
  type        = string
  description = "Git branch mapped to production deployments."
  default     = "main"
}
