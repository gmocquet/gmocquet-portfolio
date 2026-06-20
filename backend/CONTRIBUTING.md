# Contributing — backend ecosystem (focus macOS 26.5.1)

## Prerequisites

- macOS 26.5.1 + [Homebrew](https://brew.sh); `git` + `gh` (GitHub auth over **SSH**).
- **`uv`** — `brew install uv` (manages Python **3.14**; see `.python-version` / `requires-python`).
- **`direnv`** — loads `.env` via the repo `.envrc` (no secret committed).
- Run **`make doctor`** from the repo root first (verifies tools + access).

Dev tools (`ruff`, `pytest`, `pre-commit`) are **pinned dev dependencies** in `pyproject.toml`,
installed by `make init` (`uv sync`) — not global.

## Setup & workflow

```bash
make init                 # uv sync (installs deps + pre-commit git hook)
uv run ruff check .       # lint     (or: make lint, from the repo root)
uv run ruff format .      # format
uv run pytest             # tests    (or: make test)
```

- **Every change via a Pull Request**; never push directly to `main` (a `pre-push` hook blocks it).
- **Conventional Commits** mandatory (drive semver tagging + `CHANGELOG.md`).
- Pin every dependency exactly; commit `uv.lock`. Definition of Done: tests green, docs updated,
  `make lint` clean.
