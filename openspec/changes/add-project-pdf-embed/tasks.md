# Tasks — add-project-pdf-embed

- [x] Pin `react-pdf` 10.4.1 in `@gmocquet/ui` (lockfile updated; `pdfjs-dist` 5.4.296 transitively)
- [x] Extend `MediaLink` (types + Zod schema): `description`, `embed`, `fullVersion`
- [x] `PdfEmbed` block (PDF.js reader, fixed-height scrollable frame, caption fallback link)
- [x] `partitionMedia` helper + vitest coverage; export both through the `@gmocquet/ui` public API
- [x] Project detail page: ordered media sections (description + fullVersion link + embed)
- [x] Content: chapter-3 PDF embedded + full white paper asset/link + talk video (YouTube)
- [x] DoD: vitest green, `make lint` clean, `make build` green, visual check on the page
