# Change: add-media-source-link

## Why

The ARTE documentary embedded on the Kpler page is hosted on Vimeo, but the canonical source is
ARTE's own page. The embed caption should credit and link the original source.

## What Changes

- **Capability `content-model`**: `media` entries gain an optional `source` field (canonical source
  page URL), validated like other media URLs and mirrored in the `@gmocquet/ui` `MediaLink`
  contract.
- **Capability `public-site`**: `VideoEmbed` renders an external-link icon right after the caption
  title, opening the source page in a new tab.
- Content: the ARTE media points to `https://www.arte.tv/fr/videos/098820-000-A/planete-finance/`.

## Impact

- `frontend/packages/ui`: `MediaLink.source` type + `VideoEmbed` caption link.
- `frontend/src`: Zod `mediaLink.source`; `frontend/content/projects.yaml`: ARTE source URL.
  Field optional — no other content changes.
