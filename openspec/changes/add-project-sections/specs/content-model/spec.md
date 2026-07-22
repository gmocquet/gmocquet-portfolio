# content-model — deltas

## ADDED Requirements

### Requirement: Titled project sections

A project SHALL support an optional `sections` list. Each section has a `title`, optional `body`
paragraphs, an optional `image` (`{src, alt}`) and an optional `media` list using the same
`mediaLink` schema as project-level media (embeds, descriptions and timecodes included). Section
headings are numbered automatically from array order.

#### Scenario: Sections render in authored order with automatic numbering

- WHEN a project declares sections
- THEN the detail page renders them after the project-level media, headed "1. <title>",
  "2. <title>", … in YAML order — reordering the array renumbers the headings

#### Scenario: A section carries text, an illustration and media

- WHEN a section declares body paragraphs, an image and media
- THEN the page renders the paragraphs, then the illustration, then the media with the exact same
  behavior as project-level media (inline embeds, descriptions, timecodes, plain links)

#### Scenario: Existing projects are unaffected

- WHEN a project declares no `sections`
- THEN the page validates and renders exactly as before the change
