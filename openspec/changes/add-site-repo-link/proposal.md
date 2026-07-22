# Change: add-site-repo-link

## Why

The repo is public: like most open-source project sites, the site should link its own source. The
footer GitHub link pointed to the personal profile, and the header had no repository link.

## What Changes

- **Capability `content-model`**: the profile gains an optional `repository` field (public source
  repository URL of this site). `contacts.github` keeps pointing to the personal profile (used by
  the contact page with the "@gmocquet" handle).
- **Capability `public-site`**: the header shows the GitHub mark (inline SVG, no new dependency)
  left of the theme toggle, opening the repository in a new tab; the footer "GitHub" link now
  targets the repository instead of the profile.

## Impact

- `frontend/src`: profile Zod schema (`repository`), `Header.astro` (icon link), `Footer.astro`
  (repository link). `frontend/content/profile/profile.yaml`: new `repository` value.
- Contact page untouched (still the personal GitHub profile).
