# Playbook — Bootstrap a two-ecosystem repo with governance

Generalized recipe to recreate this project's foundation elsewhere.

## 1. Repo & knowledge

1. `README.md` holds the business context; `CLAUDE.md` imports it via `@README.md` (auto-loaded).
2. Knowledge lives in flat, versioned files only (README, CLAUDE.md, `.claude/settings.json`,
   `openspec/`, `docs/`). No external memory.

## 2. Tooling (single entry point)

1. Root `Makefile` with one-liner targets delegating to `scripts/` (no logic > a few lines).
2. `scripts/doctor.sh` preflight (tools + access), `scripts/github-bootstrap.sh` governance.
3. `.envrc` with `dotenv_if_exists .env` (committed, no secrets); `.env` git-ignored.

## 3. Two ecosystems

1. `frontend/` (npm workspaces: app + `packages/ui`) and `backend/` (uv), each self-contained
   (README, CONTRIBUTING, lockfile, `.gitignore`, `.pre-commit-config.yaml`).
2. One `.pre-commit-config.yaml` per ecosystem; `make lint` applies each explicitly.

## 4. Governance & automation

1. `gh`-scripted: private repo, milestones, labels, issues, project board, `main` protection (PR-only).
2. Conventional Commits → `release-tag.yml` (semver tag on push to main) → `changelog.yml`
   (`CHANGELOG.md` via git-cliff on tag).
3. Spec-driven changes under `openspec/`.
