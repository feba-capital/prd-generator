# Changelog

All notable changes to the `prd-generator` plugin are documented in this file.

## [Unreleased]

## Hotfix: Version Policy

### Changed
- Added a Version Policy to the skill so generated docs prefer the current stable or LTS runtime and framework versions, and stale preset hardcodes are no longer treated as safe defaults.
- Updated the `nextjs-supabase` preset to target the current Node.js LTS line and the current Next.js stable line instead of outdated guidance.
- Added a version currency check to the validator so bare or stale Node / Next.js references fail the quality gate.
- Updated default owner labeling in generated docs to `**Owner:** Fabio Espindula - FEBACAPITAL`.

### Added
- Sprint 1 quality gate coverage for Finding 1: cross-doc consistency checks across PRD workflows, endpoint contracts, model fields, and Supabase RLS summaries.
- Sprint 1 quality gate coverage for Finding 3: workflow steps must end with an exact endpoint reference or a `UI only` marker.
- Sprint 1 quality gate coverage for Finding 6: RLS lint rules for non-admin `UPDATE` policies, including transition comments and explicit enforcement metadata.
- Sprint 1 template coverage for Finding 7: mandatory `Implementation Readiness` section with source citations and non-empty subsections.

### Changed
- Sprint 1 uncertainty labeling for Finding 4: `TBD`, `Assumed`, and `Proposed` now require explicit classifiers that drive implementation-readiness synthesis.
- Sprint 1 validator now supports a strict generation mode while preserving compatibility with previously generated packages that still use legacy `TBD (reason: ...)` labels.

### Migration Notes
- Packages generated before Sprint 1 may fail the upgraded validator until they are regenerated with the new templates. Legacy `TBD (reason: ...)` labels remain readable, but older packages do not contain the new structured cross-doc metadata or the mandatory `Implementation Readiness` section.
