# Tasks — add-public-portfolio-site

Work breakdown, mapped to the milestones in the approved plan.

## M0 — Bootstrap & governance
- [x] Root governance & tooling (README, CLAUDE.md @README.md, settings.json, Makefile, scripts/, .envrc, .gitignore)
- [x] Expert agents (frontend-ux, infra-cloud, backend-python)
- [x] ADRs (0001–0004), playbooks, build-log
- [x] CI: release-tag.yml + changelog.yml + cliff.toml
- [x] OpenSpec change proposal (this document)
- [ ] GitHub governance via scripts/github-bootstrap.sh (milestones, labels, issues, board, branch protection) — needs `gh`

## M1 — Foundations
- [x] frontend/ ecosystem: npm workspaces (Astro app + packages/ui @gmocquet/ui), Tailwind v4 tokens
- [x] backend/ ecosystem skeleton: pyproject.toml (uv) + uv.lock + src/ placeholder
- [x] Per-ecosystem README, CONTRIBUTING, .gitignore, .pre-commit-config.yaml
- [x] Pin exact versions + lockfiles; `make lint` green

## M2 — Content (data)
- [ ] content.config.ts (Zod schemas) + loaders -> content/
- [ ] Scaffold EN YAML from CV PDF; declare media (youtube/pdfs/links/slideshare); curate EN

## M3 — Pages & design
- [ ] Content-agnostic components + block registry
- [ ] Home, About, Projects + detail, Contact; dark-first luxe; responsive; perf budget (Lighthouse ≥ 95)

## M4 — i18n & translation
- [ ] Astro i18n routing (EN source, /fr generated)
- [ ] Translation CLI (Claude OAuth) with hash-based idempotent regeneration; generate + curate FR

## M5 — Deployment
- [ ] deploy.yml -> Cloudflare Pages; DNS delegation OVH→Cloudflare; Web Analytics; domain live (HTTPS)

## Done when
- All of the above checked; Definition of Done met (build green, docs/specs updated, lint/hooks clean).
