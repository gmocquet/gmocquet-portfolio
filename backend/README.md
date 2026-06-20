# Backend ecosystem (Python / FastAPI)

Self-contained Python ecosystem, extractable to its own repository. **Anticipated skeleton in Lot 1**
— no business logic yet; the public site ships fully static with no Python runtime.

- **Lot 2 (later):** private-area API — token-based access with **configurable validity**, revocation,
  and a back-office — built with **FastAPI** + **Pydantic v2**, deployed serverless (Lambda-type).
- **Contract with the frontend:** the HTTP API (Pydantic v2 → OpenAPI). Never shared code or state.

## Stack & tooling

- **Python 3.14** managed by **`uv`** (`requires-python` in `pyproject.toml`, pinned `uv.lock`).
- **`ruff`** (lint + format), **`pytest`** (tests), **`pre-commit`** (all pinned dev dependencies).

## Common tasks

From the repo root, the `Makefile` is the single entry point (`make init`, `make lint`, `make test`).
Inside this ecosystem you can also use `uv` directly:

```bash
uv sync                 # install the locked environment
uv run ruff check .     # lint
uv run ruff format .    # format
uv run pytest           # tests
```

See `CONTRIBUTING.md` for prerequisites (focus macOS 26.5.1).
