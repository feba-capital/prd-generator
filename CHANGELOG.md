# Changelog

All notable changes to the `prd-generator` plugin are documented in this file.

## [Unreleased]

## Sprint 2: v2 Flow Redesign

### Added
- Added Step 0 language selection so the PRD workflow can run in English, Brazilian Portuguese, or a user-specified language with a quality caveat.
- Added Step 1 brainstorm-readiness so raw ideas can hand off cleanly to brainstorming before the formal PRD workflow starts.
- Added Step 2 optional MVP check with the 7-question scope contract flow, the override pattern, and optional standalone scope-contract export.
- Added Sprint 2 quality gates for mutually exclusive `Future Versions` vs `Launch Dependencies`, `Scope Decisions` justifications, and `Validation Plan` completeness.
- Added Sprint 2 regression fixtures covering language cascade, future versions, launch dependencies, validation plans, scope overrides, rewrite flows, and the scope-contract export path.

### Changed
- Updated the main PRD template to emit `Future Versions`, `Launch Dependencies`, `Validation Plan`, and `Scope Decisions` only when the Step 2 signals require them.
- Updated the validator to understand PT-BR PRD headings and readiness sections while keeping backward compatibility for pre-Sprint 2 English packages such as Orchestrix.
- Minor-bumped the plugin for the v2 entry-flow redesign and the expanded 16-gate quality check.

## Sprint 1.5: Validator Hardening

### Added
- Added `access-control-consistency` to the validator so role claims in the PRD, endpoint contracts, and underlying RLS policy text must agree for the same action.
- Added `workflow-anchor-uniqueness` to the validator so duplicate workflow endpoint anchors now require a distinct role, state, or anchor qualifier.
- Added dedicated pass and fail fixtures for both new checks, wired into the existing validator harness.

### Changed
- Patch-bumped the plugin after expanding the quality gate from 11 to 13 checks.

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
