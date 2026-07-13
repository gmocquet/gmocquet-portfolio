# Changelog

All notable changes to this project are documented here.
## [0.1.0] - 2026-07-13

### Features
- *(ci)* Fold the changelog into release-tag (regenerate + commit before the tag) (#34) by @gmocquet

## [0.0.10] - 2026-07-13

### Refactor
- *(ci)* Rename repo-settings-gh-pat-token-* targets to repo-settings-token-* (#33) by @gmocquet

## [0.0.9] - 2026-07-13

### Features
- *(ci)* Harden the GH_PAT_TOKEN tooling (verify on set, revoke on delete) (#32) by @gmocquet

### Bug Fixes
- *(ci)* Push release tags with a fine-grained PAT so deploy triggers (#31) by @gmocquet

## [0.0.8] - 2026-07-10

### Chore
- *(content)* Refresh Quantmetry MLOps white paper PDF (#30) by @gmocquet

## [0.0.7] - 2026-06-25

### Tests
- *(ci)* Release-tag from github-tag-action doc example 1 (GITHUB_TOKEN) (#29) by @gmocquet

## [0.0.6] - 2026-06-25

### Tests
- *(ci)* Create the tag with anothrNick/github-tag-action (GITHUB_TOKEN) (#28) by @gmocquet

## [0.0.5] - 2026-06-25

### Chore
- *(ci)* Use block-form branches trigger in release-tag (#27) by @gmocquet

## [0.0.4] - 2026-06-25

### Chore
- *(ci)* Clean up deploy/changelog triggers (drop workflow_dispatch, block-form tags) (#26) by @gmocquet

## [0.0.3] - 2026-06-25

### Tests
- *(ci)* Create release tag via GitHub API (GITHUB_TOKEN) to verify deploy trigger (#25) by @gmocquet

## [0.0.2] - 2026-06-25

### CI/CD
- *(deploy)* Trigger on v* release tags (#24) by @gmocquet

## [0.0.1] - 2026-06-24

### Features
- Scaffold frontend and backend ecosystems (M1) by @gmocquet
- Model portfolio content as ordered YAML lists (M2) by @gmocquet
- Render content into pages with a luxe design system (M3) by @gmocquet
- *(media)* Embed videos inline on project pages by @gmocquet
- *(tags)* Skill matcher page (replaces full-text search) by @gmocquet
- *(deploy)* Cloudflare Pages via OpenTofu + CI (M5) by @gmocquet
- *(infra)* Delegate DNS to Cloudflare, replicate OVH mail records (ADR 0007) by @gmocquet
- *(infra)* Publish DMARC record (p=quarantine) (#18) by @gmocquet
- *(ci)* Semver bump policy (patch default, minor on feat, major on breaking) (#23) by @gmocquet

### Bug Fixes
- *(home)* De-emphasize role count; clarify projects listing by @gmocquet
- *(make)* Use /bin/bash as SHELL for CI compatibility by @gmocquet
- *(infra)* Silence perpetual SRV priority drift (#19) by @gmocquet
- *(infra)* Harden SPF to hardfail (-all) (#20) by @gmocquet
- *(ci)* Create initial v0.1.0 tag when none exists (#22) by @gmocquet

### Refactor
- *(contacts)* Purge residual email/website handling by @gmocquet

### Documentation
- *(readme)* Add git-filter-repo to required global tooling by @gmocquet

### CI/CD
- Bump actions/checkout to v7.0.0 (run on Node 24) (#21) by @gmocquet

### Chore
- Bootstrap project governance, tooling and CI (M0) by @gmocquet
- *(content)* Show only LinkedIn and GitHub contacts by @gmocquet
- *(infra)* Move Terraform state to Cloudflare R2 by @gmocquet
- *(secrets)* Adopt Infisical as the secrets source of truth (#17) by @gmocquet


