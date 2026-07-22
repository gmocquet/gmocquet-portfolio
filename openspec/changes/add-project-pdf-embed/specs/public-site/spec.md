# public-site — deltas

## ADDED Requirements

### Requirement: Inline PDF reader block

The `@gmocquet/ui` library SHALL provide a content-agnostic `PdfEmbed` block rendering a PDF.js
reader (`react-pdf`) for `pdf` media: pages at container width inside a fixed-height scrollable
frame, with a caption keeping a permanent plain link to the file. PDF.js touches browser APIs at
import time, so the viewer chunk SHALL only ever load in the browser (client-only island, viewer
code-split behind `React.lazy`), keeping the library barrel importable during static prerender.

#### Scenario: Embedded chapter renders inline

- WHEN a visitor opens a project page whose media embeds a PDF
- THEN the PDF pages render inline at container width in a scrollable frame, and the caption shows
  the media label, the page count and an "Open" link to the file

#### Scenario: Static build stays green

- WHEN the site is statically built (Node prerender, no browser APIs)
- THEN importing the `@gmocquet/ui` public API does not load PDF.js and the build succeeds

#### Scenario: Ordered media sections

- WHEN a project declares several embeddable media (videos, opted-in PDFs)
- THEN the detail page renders one section per media in the authored YAML order, each with its
  optional description, separated by consistent vertical spacing
