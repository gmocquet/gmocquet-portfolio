# Tasks — add-media-timecodes

- [x] Extend `MediaLink` (types + Zod schema): `start`, `timecodes` (grouped, timecode-validated)
- [x] `timecodeToSeconds` + `mediaUrlAt` helpers; `toEmbedUrl` honors `start` (YouTube/Vimeo)
- [x] `MediaTimecodes` island (grouped moments; click seeks the embedded player, icon opens the
      platform in a new tab) + public API export
- [x] Project detail page renders `MediaTimecodes` under each embedded media
- [x] Content: Kpler ARTE video starts at 17:14 + two timecode groups
- [x] DoD: vitest green, `make lint` clean, `make build` green, visual check on the page
