# 0002 — Static Astro site on Cloudflare Pages

- **Status**: Accepted (2026-06-20)

## Context

The public site targets a handful of visitors per year, must be responsive with very low load times,
JAMstack/headless (no WordPress), and hosted on a free tier. No authentication in Lot 1.

## Decision

Build the site with **Astro 6 in static output** (`output: 'static'`, no adapter) and **React
islands** (`@astrojs/react`) hydrated selectively (`client:visible`/`client:idle`). Style with
**Tailwind CSS v4** via the `@tailwindcss/vite` plugin (not the v3 `@astrojs/tailwind` integration).
Self-host fonts via Astro's Fonts API. Deploy the static output to **Cloudflare Pages** (free tier)
with **Cloudflare Web Analytics** (cookieless). Domain `guillaumemocquet.com` with DNS delegated
**OVH → Cloudflare**.

## Consequences

- Excellent performance and cost (fully static, global CDN), no server runtime to operate.
- Interactivity/animation must be deliberate (islands only) to preserve the performance budget.
- The Python backend cannot run on this hosting; it targets serverless/other hosting in later lots.
