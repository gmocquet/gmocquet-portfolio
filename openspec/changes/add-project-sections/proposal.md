# Change: add-project-sections

## Why

The Kpler page needs to present several distinct product stories (Product Estimation, Destination
Forecast, Cushing drone inventories) instead of one flat media list. Project pages need a notion of
titled paragraphs that can each carry text, an illustration and media.

## What Changes

- **Capability `content-model`**: a project gains an optional `sections` list — each section has a
  `title` (headings are auto-numbered from array order, so reordering renumbers), optional `body`
  paragraphs (same shape as the profile `summary`), an optional `image` (`{src, alt}`, stored under
  `public/assets`) and an optional `media` list (same `mediaLink` schema as project-level media,
  embeds/timecodes included). Mirrored in the `@gmocquet/ui` `ProjectData` contract.
- **Capability `public-site`**: the media rendering of the project detail page (embeds with
  descriptions, timecodes, plain links) is extracted into a reusable `ProjectMedia.astro`
  component, used for project-level media and per-section media.
- Content: the Kpler project now has three sections — "1. Product Estimation" and
  "2. Destination Forecast" as "Coming soon." placeholders, and "3. Cushing drone inventories"
  carrying the drone-imagery pitch, the Cushing aerial photo (new local asset) and the ARTE
  documentary (start time + timecodes untouched).

## Impact

- `frontend/src`: extended Zod `projects` schema, new `components/ProjectMedia.astro`, section
  rendering in `pages/projects/[id].astro`.
- `frontend/packages/ui`: `ProjectData.sections` type.
- `frontend/content/projects.yaml` + `frontend/public/assets/`: Kpler media moved under section 3;
  new `kpler-cushing-drone-inventories.webp` (153 KB). Other projects unchanged (field optional).
