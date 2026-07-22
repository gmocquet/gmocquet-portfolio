# content-model — deltas

## ADDED Requirements

### Requirement: Titled project sections

A project SHALL support an optional `sections` list. Each section has a `title`, optional `body`
paragraphs, an optional `image` (`{src, alt}`), an optional `source` (canonical source URL of the
section content, rendered as a "Source: <host>" external link with icon right after the
body/illustration) and an optional `media` list using the same `mediaLink` schema as project-level
media (embeds, descriptions and timecodes included).

#### Scenario: Sections render in authored order

- WHEN a project declares sections
- THEN the detail page renders them after the project-level media, each headed by its plain
  title, in YAML order

#### Scenario: A section carries text, an illustration and media

- WHEN a section declares body paragraphs, an image and media
- THEN the page renders the paragraphs, then the illustration, then the media with the exact same
  behavior as project-level media (inline embeds, descriptions, timecodes, plain links)

#### Scenario: Existing projects are unaffected

- WHEN a project declares no `sections`
- THEN the page validates and renders exactly as before the change
