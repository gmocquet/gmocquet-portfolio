# 0008 — Remote OpenTofu state in Cloudflare R2 (private, no passphrase)

- **Status**: Accepted (2026-06-24).

## Context

ADR 0005/0007 provisioned the Cloudflare platform with OpenTofu and, as an interim, the state
(`infra/cloudflare/terraform.tfstate`) was **committed to this private, single-operator repo**. The
state holds **no credentials** (the provider token comes from the environment), only Cloudflare
resource IDs and public DNS records — but a committed state still bloats history, exposes the infra
topology, and is the wrong default before the repo goes public or gains other operators. It needs a
**secure, out-of-git, free** home.

Options weighed: HCP Terraform (free tier, but another vendor + account), AWS S3 + a lockfile (works,
but pulls AWS into a Cloudflare-only project), GitLab-managed state (wrong forge). Cloudflare **R2**
wins: same vendor as the infra, S3-compatible (native OpenTofu `s3` backend), permanent free tier
(10 GB, egress free; the state is ~38 KB).

## Decision

Store the state in a **private R2 bucket** `gmocquet-portfolio-tfstate` (object key
`cloudflare/terraform.tfstate`) via the OpenTofu **`s3` backend** (`infra/cloudflare/backend.tf`).
R2 specifics: `region = "auto"`, the account S3 endpoint
`https://<account_id>.r2.cloudflarestorage.com`, `use_path_style`, `use_lockfile` (locking via a lock
object), and the AWS-only preflight calls disabled (`skip_credentials_validation`,
`skip_metadata_api_check`, `skip_region_validation`, `skip_requesting_account_id`, `skip_s3_checksum`).

**No client-side passphrase encryption.** Recoverability is the explicit priority: a lost passphrase
must never mean a lost state, and the state carries no secrets. Confidentiality rests on the bucket
being **private** (no `r2.dev` / custom domain) and the R2 API token being scoped to that bucket only.

The S3 credentials are the R2 API token's **Access Key ID / Secret Access Key**, read from
`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (env via direnv, gitignored) — never committed. The
account id and endpoint are public, so `backend.tf` is committed as-is.

The committed state is removed from the working tree in the same change and **purged from git history**
afterwards (a history rewrite can't go through a PR), so the historical blob is gone, not merely
untracked.

## Consequences

- State lives out of git, in a durable private bucket; the repo can go public without exposing it.
- Recoverable by design: no passphrase to lose; before risky ops run `tofu state pull > backup`
  (off-git); last resort, re-`import` the live Cloudflare resources into a fresh state — the `.tf`
  files are the source of truth.
- A new operator needs an R2 API token (Object Read & Write, scoped to the bucket) in their `.env`.
- R2 has **no native object versioning**, so there is no server-side state history — the off-git
  backup before risky changes is the safety net.
- CI is unaffected: `deploy.yml` runs `wrangler` (artifact upload), not `tofu`, so no backend creds in CI.
