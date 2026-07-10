# 0010 — Release tags pushed with a fine-grained PAT (so `deploy` triggers)

- **Status**: Accepted (2026-07-10).

## Context

`deploy.yml` triggers on `push: tags: v*`; the tags are created by `release-tag.yml` on push to
`main`. That job pushed the tag with the automatic **`GITHUB_TOKEN`** — and GitHub deliberately does
**not** start new workflow runs from events created by `GITHUB_TOKEN` (anti-recursion; only
`workflow_dispatch` / `repository_dispatch` are exempt). So the tag push never reached `deploy.yml`.
Since the release-driven-deploy switch (PR #24), **no deploy had run**: `v0.0.8` (the white-paper
refresh) was tagged but the live site stayed stale.

Options weighed to make the tag push trigger `deploy`:

- **Fine-grained PAT for the tag push** — the push comes from a real user identity, so it triggers
  downstream workflows natively; `deploy.yml` stays purely tag-driven. Cost: one long-lived secret.
- **GitHub App token** (short-lived) — avoids a *long-lived token*, but requires creating an App and
  storing its **private key** as a secret (still a long-lived secret) — more moving parts for a solo
  repo.
- **`release-tag` dispatches `deploy`** via `workflow_dispatch` (`GITHUB_TOKEN`-only, no new secret)
  — but it couples the two workflows and loses the "deploy exactly this tag" semantics.
- **`workflow_run` chaining** — fires on every `main` push, needs a `conclusion == success` filter,
  and checks out `main` rather than the tagged ref.

## Decision

**`release-tag.yml` pushes the `v*` tag with a fine-grained PAT** — `secrets.GH_PAT_TOKEN`, scope
**Contents: Read and write on this repo only**, and **No expiration by default**
(`PAT_EXPIRES_IN=none`, matching neo; set `PAT_EXPIRES_IN=<days>` for a bounded expiry).
`deploy.yml` is unchanged (`on: push: tags: v*`).

- **Stored as a GitHub Actions secret** (not Infisical), managed reproducibly by
  `make repo-settings-gh-pat-token-{set,status,delete}` → `scripts/repo-settings-gh-pat-token.sh`.
  `-set` opens the **pre-filled** fine-grained-PAT page (name, description, expiry, Contents:write —
  the user only picks the repository, which GitHub cannot pre-select), then **verifies the token can
  actually create a tag before storing it**: it creates and deletes a throwaway **non-`v*`** ref via
  the same `POST git/refs` the workflow uses (the call that 404'd with a mis-scoped PAT), and refuses
  a token that fails — turning the earlier silent failure into fail-fast. A stored Actions secret is
  **write-only**, so this is the only place its rights can be checked with the token in hand; `-status`
  re-runs the same probe on a token passed via `GH_PAT_TOKEN`, otherwise it only confirms presence.
  `-delete` removes the secret and opens the fine-grained-tokens page to revoke the PAT itself —
  GitHub exposes **no API to delete a user's own PAT** (the OAuth Authorizations API was retired in
  2020; the fine-grained-PAT API is org-only and App-only), so that last step stays manual. The
  tooling is ported from `gmocquet/neo` (`repo-settings-token-*`), renamed and adapted to this repo's
  conventions (Makefile one-liners → `scripts/`, bats-tested).

**Documented exception to ADR 0009** ("no static secret stored in GitHub"; CI secrets via OIDC):
there is **no OIDC path to authenticate a git tag push as a user**. This PAT is a GitHub-native
bootstrap credential, used only inside Actions; the exception is deliberately narrow — minimal scope
(Contents:write, one repo), one-command rotation/deletion, and an optional bounded expiry.

## Consequences

- Merging any PR to `main` again produces a tag that **triggers `deploy`**; the next tag (`v0.0.9`)
  self-heals the un-deployed `v0.0.8` by deploying current `main` (which already carries it).
- One long-lived, **non-expiring-by-default** secret returns to GitHub, by necessity. Mitigations:
  minimal scope, trivial rotation (`make repo-settings-gh-pat-token-set`) and revocation
  (`make repo-settings-gh-pat-token-delete` + delete the PAT on GitHub); it can write nothing but
  refs/contents on this single repo. Set `PAT_EXPIRES_IN=<days>` for a bounded expiry instead.
- **Rotation** (only when a bounded expiry is set): an expired PAT silently fails the tag push (red
  `release-tag` run). Re-run the `-set` target to rotate; `-status` reports presence.
- The `repo-settings-gh-pat-token-*` tooling is reusable to provision any repo's CI PAT.
