# Agentic Coding — build log

Chronological journal of how this project is built with a piloted team of expert agents. Doubles as a
generalizable draft for LinkedIn/blog articles. Most recent entry **last**.

## 2026-06-20 — M0: bootstrap & governance

- Approved an incremental plan (Lot 1 = public showcase site) after a deep requirements pass.
- Chose a two-ecosystem repo (`frontend/` TS/React/Astro, `backend/` Python skeleton), content as
  YAML decoupled from presentation, EM-first positioning, Cloudflare Pages hosting.
- Scaffolded root governance & tooling: `README.md` + `CLAUDE.md` (`@README.md` import),
  `.claude/settings.json`, `Makefile` (one-liner task runner) + `scripts/` (doctor, init, lint, test,
  deploy, github-bootstrap), `.envrc` (direnv), root `.gitignore`, ADRs (0001–0004) and playbooks.
- Recorded environment gaps surfaced by `make doctor` (uv, gh, pre-commit, direnv, wrangler, …) — to
  be installed per `CONTRIBUTING.md`.

## 2026-06-21 — M1: foundations (both ecosystems)

- **backend/** (uv, Python 3.14.6): FastAPI/Pydantic/uvicorn declared (skeleton, no business logic);
  dev deps ruff/pytest/pre-commit; exact pins + `uv.lock`; ruff config; README/CONTRIBUTING/.gitignore.
- **frontend/** (npm workspaces): Astro 6.4.8 static + React 19 islands + Tailwind v4 (`@tailwindcss/vite`)
  with `@theme` design tokens; `@gmocquet/ui` library (shadcn-style `Button` on cva/clsx/tailwind-merge),
  consumed via its public API as a hydrated island; Biome; exact pins via `.npmrc` + `package-lock.json`.
  `pre-commit` managed as a uv dev dep (Python) per ecosystem, orchestrating Biome/ruff.
- Wired `scripts/lint.sh` to run pre-commit via `uv run --project <eco>`; each hook runs from its own
  ecosystem dir (correct tool root). **`make build` / `make lint` / `make doctor` all green.**
