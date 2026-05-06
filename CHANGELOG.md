# Changelog

All notable changes to the `prd-generator` plugin are documented in this file.

## [1.3.1] - Validator hotfix and PRD numbering fix

### Fixed
- **PRD template numbering** is no longer duplicated. Both `multitenant=yes` and `multitenant=no` branches now render `## 1.` through `## 10.` sequentially. Previously, `multitenant=yes` emitted `## 2.` twice (Tenancy & Users + Data Model) and `multitenant=no` emitted `## 5.` twice (API Design + Infrastructure & Operations).
- **Validator no longer silently skips cross-doc checks for non-Supabase stacks.** `check_cross_doc_consistency`, `check_workflow_anchor_uniqueness`, and `check_rls_lint` were previously gated on the existence of `SUPABASE-PATTERNS.md`. For Yii2/MySQL projects the gate evaluated to false and the validator skipped all three checks, allowing endpoint/model mismatches and unreferenced workflow endpoints to ship undetected. The Supabase-only portions now skip gracefully when the file is absent, while stack-agnostic portions (PRD ↔ endpoints ↔ models, workflow anchor uniqueness) run on every project.

### Known follow-ups
- Add a `pass-no-supabase` fixture under `tests/quality/` so a future regression of the validator gate is caught by the regression suite. Tracked for v1.4.
- Add a `## N.` section-number uniqueness check to the validator so a future regression of the template numbering is caught automatically. Tracked for v1.4.

## [1.3.0] - First public release

### Added
- LICENSE file (MIT) for public distribution.
- CONTRIBUTING.md with test, preset, and commit conventions.
- Multi-language Step 0 selection covering English, Brazilian Portuguese, Spanish, Chinese (Simplified), and a user-specified fallback. Translation now happens at generation time instead of via per-language template blocks.

### Changed
- Removed personal references from the skill, templates, interview prompts, and test fixtures. Generated PRDs now refer to "the owner" / "the user" instead of a hardcoded individual name.
- Translated `briefing-parser.md` and `questions.md` from Portuguese to English. Generalized example public-target options.
- Removed hardcoded owner default and internal observability domain from the briefing parser. The skill now derives the owner from `git config user.name` or asks.
- Anonymized the `examples/wisercontent` reference snapshot.
- Simplified plugin identity: repo, plugin, and marketplace are all `prd-generator`. Dropped the `-v2` and `-marketplace` suffixes used during the migration period.
- Bumped plugin author to `FEBA Capital` in both Claude and Codex manifests.
- Replaced rigid `{{#LANGUAGE_IS_PT_BR}}` template blocks with a single English-authored template plus a translation rule.

### Removed
- Internal incident postmortem from the repository root.

## [1.2.0] - Sprint 2: v2 Flow Redesign

### Added
- Added Step 0 language selection so the PRD workflow can run in English, Brazilian Portuguese, or a user-specified language with a quality caveat.
- Added Step 1 brainstorm-readiness so raw ideas can hand off cleanly to brainstorming before the formal PRD workflow starts.
- Added Step 2 optional MVP check with the 7-question scope contract flow, the override pattern, and optional standalone scope-contract export.
- Added Sprint 2 quality gates for mutually exclusive `Future Versions` vs `Launch Dependencies`, `Scope Decisions` justifications, and `Validation Plan` completeness.
- Added Sprint 2 regression fixtures covering language cascade, future versions, launch dependencies, validation plans, scope overrides, rewrite flows, and the scope-contract export path.

### Changed
- Updated the main PRD template to emit `Future Versions`, `Launch Dependencies`, `Validation Plan`, and `Scope Decisions` only when the Step 2 signals require them.
- Updated the validator to understand PT-BR PRD headings and readiness sections while keeping backward compatibility for pre-Sprint 2 English packages.
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
