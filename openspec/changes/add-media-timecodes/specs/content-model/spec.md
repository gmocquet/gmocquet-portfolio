# content-model — deltas

## ADDED Requirements

### Requirement: Media start time and notable moments

A `media` entry SHALL support two optional, backward-compatible fields: `start` (a "MM:SS" /
"H:MM:SS" timecode the embedded player starts at) and `timecodes` (notable moments grouped under
optional headings; each item has a timecode `at` and a `label`). Both are validated by the Zod
`mediaLink` schema (timecode format enforced) and mirrored in the `@gmocquet/ui` `MediaLink`
contract.

#### Scenario: Embedded video starts at the configured moment

- WHEN a video media declares `start: "17:14"`
- THEN the embedded player URL starts playback at 1034 seconds (YouTube `?start=`, Vimeo `#t=`)

#### Scenario: Notable moments render below the embed

- WHEN a media declares `timecodes` groups
- THEN the detail page renders each group heading and its moments below the embed
- AND clicking a timecode seeks the embedded player above to that moment and plays, without
  leaving the page (Vimeo/YouTube postMessage API)
- AND an external-link icon next to each timecode opens the video at that moment on the original
  platform, in a new tab

#### Scenario: Existing content is unaffected

- WHEN a `media` entry declares neither `start` nor `timecodes`
- THEN the entry validates and renders exactly as before the change
