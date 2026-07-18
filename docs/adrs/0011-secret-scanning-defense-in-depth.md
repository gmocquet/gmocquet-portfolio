# 0011 — Secret scanning: defense-in-depth with gitleaks (works while private)

- **Status**: Accepted (2026-07-18).

## Context

The repo is being prepared to go **public**. GitHub ships **secret scanning** and **push protection**,
but they are **free only on public repositories** — on a private personal repo they require GitHub
Advanced Security (Enterprise-tier), which this account does not have. Enabling them via the API on
the private repo returns `422 — Secret scanning is not available for this repository`.

A one-off history audit (all 53 commits, every ref) found **no committed secret**: `gitleaks`
reported no leaks, no real `.env` / `*.tfstate` / `terraform.tfvars` / private key was ever committed,
and the only sensitive-named files hold placeholders (`.env.example`, `terraform.tfvars.example`), an
Infisical **project id** (`.infisical.json` — not a credential), or public DNS records (`infra/`).

Two gaps remain: (1) the audit is a snapshot — nothing prevents a **future** leak while the repo is
still private and GitHub's native scanning is unavailable; (2) once public, native scanning is
reactive (it alerts after a push), so a purely local guard is still worth having.

## Decision

Add **defense-in-depth secret scanning with `gitleaks`**, independent of the repo's visibility, wired
through the existing Makefile + `scripts/` task runner (ADR 0004) so local and CI run the **same**
command:

- **`scripts/secret-scan.sh`** — one entry point, two modes: default scans the **full history**
  (`gitleaks git --log-opts=--all`), `--staged` scans **staged changes** (`gitleaks git --staged`,
  for pre-commit). A missing `gitleaks` **skips** locally (never blocks a commit); CI enforces it.
- **`make secret-scan`** — runs the full-history scan; bats-tested (`scripts/tests/secret-scan.bats`).
- **Pre-commit hook** (installed by `make init`) — runs `lint.sh --staged` **then**
  `secret-scan.sh --staged`, so a leak is blocked *before* it is committed.
- **CI** — `.github/workflows/security.yml` runs `make secret-scan` on every push to `main` and every
  PR, on a **full checkout** (`fetch-depth: 0`) with a **pinned** gitleaks (version kept in sync with
  the local one). This catches anything that bypassed the local hook (e.g. `--no-verify`).

`gitleaks` is a **recommended global tool** (`brew install gitleaks`, surfaced by `make doctor`), not
a pinned per-ecosystem dev dependency: secret scanning is repo-wide (it must see `infra/`, `scripts/`,
root files), so it does not belong to the frontend or backend `.pre-commit-config.yaml`.

**Day-of-publication runbook** — when the repo is made public, enable GitHub's native scanning as the
outer layer (it does not replace gitleaks; it adds server-side push protection):

```bash
# 1. Flip visibility (irreversible — the whole history becomes world-readable; audit first).
gh repo edit gmocquet/gmocquet-portfolio \
  --visibility public --accept-visibility-change-consequences

# 2. Enable native secret scanning + push protection (now free on the public repo).
gh api -X PATCH repos/gmocquet/gmocquet-portfolio \
  -F 'security_and_analysis[secret_scanning][status]=enabled' \
  -F 'security_and_analysis[secret_scanning_push_protection][status]=enabled'
```

## Consequences

- A secret can no longer be committed unnoticed: the local hook blocks it pre-commit, and CI blocks
  the PR/branch if the hook was bypassed — **while the repo is private**, without GitHub Advanced
  Security.
- Contributors need `gitleaks` locally for the pre-commit layer; without it the scan is skipped (with
  a notice) and CI remains the backstop. `make doctor` flags its absence.
- The gitleaks version is pinned in CI and should track the local Homebrew version; a drift only
  changes which built-in rules apply, never correctness of the pipeline.
- Going public later is a **two-command** step (above); native scanning then layers on top of this
  one, giving server-side push protection GitHub can enforce for every contributor.
