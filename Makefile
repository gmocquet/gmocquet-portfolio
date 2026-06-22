# Single entry point for all repo actions. Targets are one-liners delegating to scripts/ or
# ecosystem tooling — no business logic here (nothing longer than a few lines). Local and CI call
# the SAME targets (single source of commands -> reproducibility). Run `make help` to list targets.

.DEFAULT_GOAL := help
SHELL := /bin/bash
.ONESHELL:

.PHONY: help doctor init dev build lint test i18n changelog deploy gh-bootstrap

help: ## List available targets
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[1m%-14s\033[0m %s\n", $$1, $$2}'

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

i18n: ## Generate FR content from EN via the translation CLI
	@npm --prefix frontend run i18n

changelog: ## (Re)generate CHANGELOG.md from Conventional Commits
	@git cliff --output CHANGELOG.md

deploy: ## Build and deploy the frontend to Cloudflare Pages
	@./scripts/deploy.sh

gh-bootstrap: ## Create GitHub governance (milestones, labels, issues, board, branch protection)
	@./scripts/github-bootstrap.sh
