# Change: add-media-timecodes

## Why

The Kpler project page embeds the ARTE documentary, but the relevant passage (EIA & drone data
analyses) sits 17 minutes in. Visitors should land on the interesting part directly and see the
notable moments at a glance.

## What Changes

- **Capability `content-model`**: `media` entries gain two optional fields — `start` ("MM:SS" /
  "H:MM:SS" timecode the embedded player starts at) and `timecodes` (notable moments grouped under
  optional headings, mirroring the experiences `highlights` group shape) — validated by Zod and
  mirrored in the `@gmocquet/ui` `MediaLink` contract.
- **Capability `public-site`**: `toEmbedUrl` honors `start` (YouTube `?start=`, Vimeo `#t=`; the
  YouTube JS API is enabled when timecodes exist); new `mediaUrlAt(media, tc)` helper links to a
  moment on the original platform; new content-agnostic `MediaTimecodes` island renders the grouped
  moments below the embed — clicking a timecode seeks the embedded player to that moment and plays
  (postMessage API, no navigation), while an external-link icon opens the moment on the platform in
  a new tab.
- Content: the Kpler ARTE video starts at 17:14 and lists one "Main interesting timecode" group and
  one "Interesting timecodes" group (5 moments).

## Impact

- `frontend/packages/ui`: `video.ts` helpers (`timecodeToSeconds`, `mediaUrlAt`, `start`-aware
  `toEmbedUrl`) + `MediaTimecodes` block, all exported through the public API; vitest coverage.
- `frontend/src`: extended Zod `mediaLink` schema; project detail page renders `MediaTimecodes`
  under each embedded media.
- `frontend/content/projects.yaml`: Kpler media gains `start` + `timecodes`. Fields are optional —
  no other content changes.
