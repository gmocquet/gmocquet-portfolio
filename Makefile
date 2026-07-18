# Single entry point for all repo actions. Targets are one-liners delegating to scripts/ or
# ecosystem tooling — no business logic here (nothing longer than a few lines). Local and CI call
# the SAME targets (single source of commands -> reproducibility). Run `make help` to list targets.

.DEFAULT_GOAL := help
SHELL := /bin/bash
.ONESHELL:

.PHONY: help doctor init dev build lint test secret-scan i18n changelog next-release-tag secrets-pull deploy gh-bootstrap \
	repo-settings-token-set repo-settings-token-status repo-settings-token-delete

help: ## List available targets
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[1m%-34s\033[0m %s\n", $$1, $$2}'

doctor: ## Preflight: required tools + access (GitHub SSH, Anthropic OAuth/API key)
	@./scripts/doctor.sh

init: ## Install dependencies + pre-commit hooks (per ecosystem)
	@./scripts/init.sh

dev: ## Run the frontend site locally
	@npm --prefix frontend run dev

build: ## Build the static frontend site
	@npm --prefix frontend run build

lint: ## Auto-format + lint + pre-commit checks (per ecosystem)
	@./scripts/lint.sh

test: ## Run tests (per ecosystem)
	@./scripts/test.sh

secret-scan: ## Scan the whole git history for secrets (gitleaks); the pre-commit hook runs the --staged variant
	@./scripts/secret-scan.sh

i18n: ## Generate FR content from EN via the translation CLI
	@npm --prefix frontend run i18n

changelog: ## (Re)generate CHANGELOG.md (PR/author enriched via GitHub API; needs GH_PAT_TOKEN). TAG=vX.Y.Z for the upcoming release
	@./scripts/changelog.sh $(TAG)

next-release-tag: ## Print the next release tag from Conventional Commits (empty when nothing to release)
	@./scripts/next-release-tag.sh

secrets-pull: ## Regenerate the local .env from Infisical (the secrets source of truth)
	@./scripts/secrets-pull.sh

deploy: ## Build and deploy the frontend to Cloudflare Pages
	@./scripts/deploy.sh

gh-bootstrap: ## Create GitHub governance (milestones, labels, issues, board, branch protection)
	@./scripts/github-bootstrap.sh

repo-settings-token-set: ## Create the CI PAT (pre-filled page) and store it as GH_PAT_TOKEN (verify rights with -status)
	@./scripts/repo-settings-token.sh set

repo-settings-token-status: ## Check the GH_PAT_TOKEN secret + the PAT in Developer settings (with GH_PAT_TOKEN=<token>, list what it grants)
	@./scripts/repo-settings-token.sh status

repo-settings-token-delete: ## Delete the GH_PAT_TOKEN Actions secret and open the tokens page to revoke the PAT
	@./scripts/repo-settings-token.sh delete
