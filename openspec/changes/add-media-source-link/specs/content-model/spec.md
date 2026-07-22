# content-model — deltas

## ADDED Requirements

### Requirement: Media source link

A `media` entry SHALL support an optional `source` field holding the canonical source page URL of
the media (e.g. the broadcaster page when the embed is hosted elsewhere), validated like other
media URLs and mirrored in the `@gmocquet/ui` `MediaLink` contract.

#### Scenario: Embed caption links the source

- WHEN a video media declares a `source` URL
- THEN the embed caption renders an external-link icon right after the title, opening the source
  page in a new tab

#### Scenario: Media without source are unaffected

- WHEN a media declares no `source`
- THEN the caption renders exactly as before the change
