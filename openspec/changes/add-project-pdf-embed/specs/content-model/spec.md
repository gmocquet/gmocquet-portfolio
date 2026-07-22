# content-model — deltas

## ADDED Requirements

### Requirement: Inline media embedding metadata

A `media` entry SHALL support three optional, backward-compatible fields: `description` (intro
paragraph shown above the media when embedded inline), `embed` (boolean, default `false`, opting a
`pdf` media into inline embedding — videos keep embedding automatically by kind), and `fullVersion`
(`{label, url}` link to the complete document when the embedded one is an excerpt). The fields are
validated by the Zod `mediaLink` schema and mirrored in the `@gmocquet/ui` `MediaLink` contract.

#### Scenario: PDF media opted into inline embedding

- WHEN a project `media` entry of kind `pdf` sets `embed: true`
- THEN the project detail page renders it as an inline PDF reader section, preceded by its
  `description` ending with the `fullVersion` link when present

#### Scenario: Media without embed opt-in stays a plain link

- WHEN a project `media` entry of kind `pdf` does not set `embed: true`
- THEN the entry keeps rendering in the reference-links row, unchanged

#### Scenario: Existing content is unaffected

- WHEN a `media` entry declares none of the new fields
- THEN the entry validates and renders exactly as before the change
