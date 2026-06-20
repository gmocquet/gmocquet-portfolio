# 0004 — Makefile + scripts/ as the single task runner

- **Status**: Accepted (2026-06-20)

## Context

We want one harmonized entry point for all repo actions, usable identically by humans and CI, with no
business logic hidden in build files.

## Decision

The root **`Makefile`** is the single entry point. Each target is a **one-liner** delegating to
**`scripts/`** (Bash/Python, testable) or to ecosystem tooling — **no business logic, nothing longer
than a few lines** in the Makefile. **Local and CI call the same `make` targets** (single source of
commands → reproducibility). `make help` lists targets. Preflight is `scripts/doctor.sh`; GitHub
governance is scripted in `scripts/github-bootstrap.sh` (no ClickOps).

## Consequences

- Reproducible, discoverable commands; CI and local stay in sync.
- Bash scripts must be kept testable (bats) per the Definition of Done.
