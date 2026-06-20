# 0001 — Two self-contained ecosystems in a single repo

- **Status**: Accepted (2026-06-20)

## Context

The project is both a portfolio (Lot 1, public site) and a reusable technology demonstrator for
future frontend/backend SaaS apps. We want frontend (TS/React/Astro) and backend (Python/FastAPI) to
evolve independently and, eventually, to live in separate repositories.

## Decision

Organize the repo as **two self-contained ecosystems**, `frontend/` and `backend/`, each with its own
`README.md`, `CONTRIBUTING.md`, dependency manifest + lockfile, `.gitignore`, `src/` and `docs/` at
its root — extractable to its own repo without refactor. There is **no build dependency** between
them; the only cross-boundary contract is the **HTTP API** (Pydantic v2 → OpenAPI), introduced in
later lots. The frontend uses npm workspaces internally to host the `packages/ui` React library
(`@gmocquet/ui`), consumed only via its public API.

In Lot 1 only `frontend/` is built; `backend/` is an anticipated skeleton (implemented in Lot 2).

## Consequences

- Clean ownership boundaries and future extraction; reusable as a starter (project vocation #2).
- Slight upfront overhead (two dependency systems, two pre-commit configs).
- No heavy monorepo tooling (no turborepo/nx) — npm workspaces only (YAGNI).
