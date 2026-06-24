# Remote state backend — Cloudflare R2 (S3-compatible). See ADR 0008.
#
# The state lives in the PRIVATE R2 bucket "gmocquet-portfolio-tfstate" (object
# "cloudflare/terraform.tfstate"), out of git. R2 has no AWS region, so region = "auto" and the
# AWS-only preflight/validation calls are skipped. The S3 credentials (the R2 API token's Access
# Key ID / Secret Access Key) are read from AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY (env, via
# direnv) — never committed. The account id and endpoint are public, so they are fine to commit.
terraform {
  backend "s3" {
    bucket = "gmocquet-portfolio-tfstate"
    key    = "cloudflare/terraform.tfstate"
    region = "auto"

    endpoints = {
      s3 = "https://f36cd11bff88eaf1c20bdc0db1507059.r2.cloudflarestorage.com"
    }

    use_path_style = true
    use_lockfile   = true

    # R2 is S3-compatible but not AWS — skip the AWS-specific preflight/validation calls.
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
