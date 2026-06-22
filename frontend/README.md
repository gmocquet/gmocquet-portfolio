# Frontend ecosystem (TypeScript / React / Astro)

Self-contained TS/React/Astro ecosystem (the public site), extractable to its own repository. Uses
**npm workspaces**: the Astro app lives at the root; the reusable React component library lives in
`packages/ui` (`@gmocquet/ui`) and is consumed only via its public API.

## Stack

- **Astro 6** (static output) + **React islands** (`@astrojs/react`), hydrated selectively.
- **Tailwind CSS v4** via `@tailwindcss/vite`; design tokens in `src/styles/global.css` (`@theme`).
- **`@gmocquet/ui`** — shadcn-style primitives (+ disciplined Magic UI accents) built on Motion.
- Content (later, M2): human-friendly **YAML** under `content/`, validated by Zod, rendered by
  content-agnostic components via a block registry.

## Layout

```
src/                 # Astro app (pages, layouts, styles)
content/             # YAML content (data, decoupled from UI) — populated in M2
packages/ui/         # @gmocquet/ui React component library (public API in src/index.ts)
```

## Common tasks

The repo-root `Makefile` is the single entry point (`make dev`, `make build`, `make lint`). Directly:

```bash
npm install          # install workspaces (exact pins via .npmrc, committed package-lock.json)
npm run dev          # local dev server
npm run build        # static build -> dist/
npm run check        # astro check (type-check .astro + TS)
npm run lint         # biome check
```

## Tags (skill matcher)

The `/tags` page lets a visitor **select skill tags** and see whether they're in the profile and
**where** they were applied. It's a React island (`@gmocquet/ui` `TagMatcher`) fed entirely by content
props — no backend, no index. The tag catalog merges the curated `profile.skills` groups with a
"Tech stack" group derived from every experience/project `stack`; selecting tags ranks the matching
experiences/projects (pure helpers in `packages/ui/src/lib/tags.ts`, unit-tested) and deep-links to
`/projects/<id>` and `/about#exp-<id>`. The selection is mirrored in a shareable `?tags=` query string.

See `CONTRIBUTING.md` for prerequisites (focus macOS 26.5.1).
