# Change: add-project-pdf-embed

## Why

The `quantmetry-mlops-white-paper` project page only listed its PDF as a plain reference link. The
white paper chapter (chapter 3, authored by Guillaume) is the core deliverable of that project and
deserves to be readable in place, together with its companion talk — without leaving the page.

## What Changes

- **Capability `content-model`**: the `media` schema gains three optional, backward-compatible
  fields — `description` (intro paragraph rendered above an inline embed), `embed` (opts a `pdf`
  media into inline embedding; videos keep embedding automatically by kind), and `fullVersion`
  (`{label, url}` link to the complete document when the embedded one is an excerpt), mirrored in
  the `@gmocquet/ui` `MediaLink` prop contract.
- **Capability `public-site`**: new content-agnostic `PdfEmbed` block in `@gmocquet/ui` — an inline
  PDF.js reader (`react-pdf` 10.4.1, pinning `pdfjs-dist` 5.4.296 transitively) rendering pages at
  container width in a fixed-height scrollable frame, with a permanent plain-link fallback in the
  caption. Mounted as a client-only React island (PDF.js needs browser APIs).
- The project detail page now renders embeddable media as ordered sections (authored YAML order):
  optional description (ending with the `fullVersion` link), then the PDF reader or video player.
  Non-embeddable media stay in the reference-links row. The split lives in a tested
  `partitionMedia` helper in `@gmocquet/ui`.
- Content: the white paper project embeds the chapter 3 PDF (with the full white paper as the
  `fullVersion` link, new 14 MB asset) and embeds the 20-minute companion talk (YouTube, via the
  existing privacy-friendly `youtube-nocookie` player).

## Impact

- `frontend/packages/ui`: new `PdfEmbed` block + `partitionMedia` helper (public API), extended
  `MediaLink` type, new `react-pdf` dependency (only loaded on pages that embed a PDF).
- `frontend/src`: extended Zod `mediaLink` schema, reworked media rendering in
  `pages/projects/[id].astro`.
- `frontend/content/projects.yaml` + `frontend/public/assets/`: chapter-3 PDF now embedded; full
  white paper added as a linked asset. No other YAML file changes (fields are optional).
