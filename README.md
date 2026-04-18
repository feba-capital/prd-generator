# PRD Generator v1

`prd-generator` is a plugin that turns a freeform product idea into a compact, implementation-ready PRD package.

The goal of v1 is not to generate polished business theater. The goal is to generate a small set of engineering-facing documents that stay aligned with each other, expose uncertainty honestly, and are safe to hand to downstream coding agents.

## What v1 is

v1 is a formal PRD workflow with:

- explicit entry through `/prd-generator`
- a narrow activation model, so normal brainstorm conversations stay normal
- reusable stack presets
- frozen example output
- a validator that checks document structure and cross-doc consistency before the package is considered done

## What v1 solves

Most AI-generated PRDs fail in one of two ways:

1. they sound complete but hide unresolved decisions
2. they generate multiple docs that contradict each other

This plugin is built to push against both.

It forces explicit uncertainty labels, requires workflow steps to anchor to real endpoints or `UI only`, and validates that the PRD, endpoint docs, model docs, and RLS summaries agree with each other.

## What v1 generates

At minimum, the workflow is designed to generate:

- a main PRD
- `AGENTS.md`
- `DEVELOPMENT-WORKFLOW.md`
- `README.md`
- `CHANGELOG.md`
- `CLAUDE.md`

For API or fullstack projects, it also generates the architecture and contract docs that usually drift first:

- `api-docs.md`
- `api-endpoints.md`
- `api-models.md`
- `service-boundaries.md`

The default output target is `projects/{project-slug}/`.

## Core v1 rules

These are the rules that define the current version:

- No hidden certainty. Unconfirmed decisions must be labeled as `TBD`, `Assumed`, or `Proposed` using the structured Sprint 1 format.
- No accidental activation. The formal workflow should start only from `/prd-generator` or an explicit request for the formal workflow by name.
- No free-floating workflows. Each workflow step in the PRD must reference a real endpoint or say `UI only`.
- No silent cross-doc contradictions. Access rules, field contracts, and RLS summaries must agree across the generated package.
- No fake implementation readiness. The PRD must end with a short `Implementation Readiness` section that separates safe work from blocking decisions and intentional deferrals.

## What v1 intentionally does not do

v1 is deliberately conservative.

It does not try to:

- auto-decide every architectural detail
- replace direct product judgment
- hide blockers behind vague prose
- overfit to a single stack
- treat opinionated defaults as universally safe when they are not yet promoted into the preset

Some defaults are still intentionally left for later versions. That is by design, not drift.

## Repository layout

- `.claude-plugin/` and `.codex-plugin/` contain plugin manifests kept aligned for local tooling compatibility.
- `commands/` contains the explicit `/prd-generator` entrypoint.
- `skills/prd-generator/` contains the workflow, templates, presets, interview prompts, and validator.
- `docs/` contains maintenance and installation notes for the plugin itself.
- `examples/` contains frozen example output used as a reference.
- `tests/` contains validator fixtures and Sprint 1 regression coverage.
- `projects/` is the default local output directory for generated PRD packages.

## Current source of truth

If you are editing the plugin, the source of truth is this repository itself.

Start here:

1. `skills/prd-generator/SKILL.md`
2. `commands/prd-generator.md`
3. `skills/prd-generator/templates/`
4. `skills/prd-generator/stack-presets/`
5. `skills/prd-generator/scripts/validate-generated-docs.sh`

## Working on the plugin

1. Edit files under `skills/prd-generator/`, `commands/`, `docs/`, or `tests/`.
2. Run `bash tests/test-validate-generated-docs.sh`.
3. Run `bash tests/test-sprint-1-regressions.sh`.
4. If the Claude plugin behavior changed, bump `.claude-plugin/plugin.json`, push the changes, and refresh or reinstall from the GitHub marketplace.

## Packaging and GitHub

This repository is kept source-only for GitHub.

- The recommended Claude distribution path is the GitHub marketplace defined in `.claude-plugin/marketplace.json`.
- Local packaged artifacts are optional development output, not the canonical installation path.
- Generated project output should not be committed here unless it is an intentional frozen example under `examples/`.

## Backward compatibility

The validator still understands older `TBD (reason: ...)` labels when reading legacy output.

New output must use the structured Sprint 1 label format.
