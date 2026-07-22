# content-model — deltas

## ADDED Requirements

### Requirement: Site repository link

The profile SHALL support an optional `repository` field holding the public source repository URL
of the site, distinct from `contacts.github` (personal profile).

#### Scenario: Header and footer link the repository

- WHEN the profile declares a `repository` URL
- THEN the header renders the GitHub mark left of the theme toggle and the footer renders a
  "GitHub" link, both opening the repository in a new tab

#### Scenario: Contact page keeps the personal profile

- WHEN the contact page lists GitHub
- THEN it keeps linking `contacts.github` (the personal profile handle), not the repository
