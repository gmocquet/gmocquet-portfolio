# Contributing — frontend ecosystem (focus macOS 26.5.1)

## Prerequisites

- macOS 26.5.1 + [Homebrew](https://brew.sh); `git` + `gh` (GitHub auth over **SSH**).
- **`fnm`** + **Node 24.17.0** — `brew install fnm` then `fnm install` (reads `.node-version`).
- **`uv`** — `brew install uv` (used here only to manage the pinned `pre-commit`).
- **`direnv`** — loads `.env` via the repo `.envrc`.
- Run **`make doctor`** from the repo root first (verifies tools + access).

Node dev tools (Astro, **Biome**, `wrangler`) are pinned `devDependencies` in `package.json`;
`pre-commit` is a pinned dev dependency in `pyproject.toml` (uv). Both are installed by `make init`.

## Setup & workflow

```bash
make init            # npm ci + uv sync + pre-commit git hook
npm run dev          # local dev          (or: make dev)
npm run build        # static build       (or: make build)
npm run check        # astro check (types)
make lint            # biome (+ pre-commit), from the repo root
```

- **Every change via a Pull Request**; never push directly to `main` (a `pre-push` hook blocks it).
- **Conventional Commits** mandatory (drive semver tagging + `CHANGELOG.md`).
- Pin every dependency exactly (`.npmrc` `save-exact`); commit `package-lock.json`. Definition of
  Done: build green, `make lint` clean, docs updated.
