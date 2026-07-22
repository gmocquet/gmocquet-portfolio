# Changelog

All notable changes to this project are documented here.
## [0.5.0] - 2026-07-22

### Features
- *(projects)* Add titled sections to project pages (#47) by @gmocquet

## [0.4.1] - 2026-07-22

### Bug Fixes
- *(content)* Align the EIA timecode with the video start (17:14) (#46) by @gmocquet

## [0.4.0] - 2026-07-22

### Features
- *(ui)* Seek the embedded player from timecode clicks (#45) by @gmocquet

## [0.3.0] - 2026-07-22

### Features
- *(projects)* Start the Kpler documentary at 17:14 and list notable timecodes (#44) by @gmocquet

## [0.2.5] - 2026-07-22

### Documentation
- *(readme)* Link the live site from the intro (#43) by @gmocquet

## [0.2.4] - 2026-07-22

### Chore
- *(deps)* Bump astro from 6.4.8 to 7.1.0 in /frontend (#38) by @dependabot[bot]

## [0.2.3] - 2026-07-22

### Chore
- *(deps)* Bump yaml and @astrojs/language-server in /frontend (#37) by @dependabot[bot]

## [0.2.2] - 2026-07-22

### Documentation
- *(readme)* State the public all-rights-reserved license (#42) by @gmocquet

## [0.2.1] - 2026-07-22

### Chore
- *(governance)* Converge the main ruleset from github-bootstrap (#41) by @gmocquet

## [0.2.0] - 2026-07-22

### Features
- *(projects)* Embed chapter 3 PDF and talk video on the white paper page (#39) by @gmocquet

### Bug Fixes
- *(ci)* Push the changelog commit with the PAT to pass the main ruleset (#40) by @gmocquet

### Chore
- *(security)* Add gitleaks secret scanning (pre-commit + CI) by @gmocquet

## [0.1.2] - 2026-07-13

### Refactor
- *(ci)* Split release-tag into two jobs (changelog, then tag) (#36) by @gmocquet

## [0.1.1] - 2026-07-13

### Bug Fixes
- *(ci)* Push the release tag as the PAT so deploy triggers (#35) by @gmocquet

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


