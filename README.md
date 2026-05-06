# PRD Generator

`prd-generator` is a plugin that turns a freeform product idea into a compact, implementation-ready PRD package.

The goal is not to generate polished business theater. The goal is to generate a small set of engineering-facing documents that stay aligned with each other, expose uncertainty honestly, and are safe to hand to downstream coding agents (Claude Code, Codex, Cursor, and similar).

## What it is

A formal PRD workflow with:

- explicit entry through `/prd-generator`
- a narrow activation model, so normal brainstorm conversations stay normal
- multi-language output (English, Brazilian Portuguese, Spanish, Chinese (Simplified), or any other language with a quality caveat)
- reusable stack presets
- frozen example output
- a validator that checks document structure and cross-doc consistency before the package is considered done

## What it solves

Most AI-generated PRDs fail in one of two ways:

1. they sound complete but hide unresolved decisions
2. they generate multiple docs that contradict each other

This plugin is built to push against both.

It forces explicit uncertainty labels, requires workflow steps to anchor to real endpoints or `UI only`, and validates that the PRD, endpoint docs, model docs, and RLS summaries agree with each other.

## What it generates

At minimum, the workflow generates:

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

## Example session

```
> /prd-generator
[skill] What language would you like to use for this session?
> English

[skill] Is this idea already brainstormed, or still raw?
> Already brainstormed

[skill] Briefly describe what you want to build:
> A multi-tenant blog platform for portfolio companies. Each tenant
> gets isolated content, AI writers, and publishing webhooks.
> Stack: Next.js 16 + Supabase. MVP needs auth, brief approval,
> content generation, scheduling.

[skill] [asks 6 high-leverage questions in 2 batches]
[skill] Confirm summary: BlogSaaS / Fullstack / Next.js + Supabase /
        Email+MFA / multi-tenant row-level / 5 MVP features
> Approve

[skill] Generated 11 files in projects/blog-saas/. All 16 quality gates
        passed. Implementation Readiness: 8 safe to implement now,
        2 need decision before coding, 3 deferred to v1.1.
```

## Core rules

- **No hidden certainty.** Unconfirmed decisions must be labeled as `TBD`, `Assumed`, or `Proposed` using the structured Sprint 1 format.
- **No accidental activation.** The formal workflow only starts from `/prd-generator` or an explicit request for the formal workflow by name.
- **No free-floating workflows.** Each workflow step in the PRD must reference a real endpoint or say `UI only`.
- **No silent cross-doc contradictions.** Access rules, field contracts, and RLS summaries must agree across the generated package.
- **No fake implementation readiness.** The PRD must end with a short `Implementation Readiness` section that separates safe work from blocking decisions and intentional deferrals.

## What it intentionally does not do

The plugin is deliberately conservative.

It does not try to:

- auto-decide every architectural detail
- replace direct product judgment
- hide blockers behind vague prose
- overfit to a single stack
- treat opinionated defaults as universally safe when they are not yet promoted into the preset

Some defaults are intentionally left for later versions. That is by design, not drift.

## Repository layout

- `.claude-plugin/` and `.codex-plugin/` contain plugin manifests kept aligned for local tooling compatibility.
- `commands/` contains the explicit `/prd-generator` entrypoint.
- `skills/prd-generator/` contains the workflow, templates, presets, interview prompts, and validator.
- `docs/` contains maintenance and installation notes for the plugin itself.
- `examples/` contains frozen example output used as a reference.
- `tests/` contains validator fixtures and Sprint 1 / Sprint 2 regression coverage.
- `projects/` is the default local output directory for generated PRD packages.

## Installation

The recommended distribution path for Claude is the GitHub marketplace defined in `.claude-plugin/marketplace.json`.

1. Add or refresh the marketplace from `feba-capital/prd-generator`.
2. Install `prd-generator` from the `prd-generator` marketplace.
3. Run `/prd-generator` in a fresh Claude session to confirm the formal workflow starts.

For Codex, the manifest is in `.codex-plugin/plugin.json` and the skill payload is the same `skills/prd-generator/` directory.

See `docs/skill-installation.md` for more detail.

## Working on the plugin

1. Edit files under `skills/prd-generator/`, `commands/`, `docs/`, or `tests/`.
2. Run `bash tests/test-validate-generated-docs.sh`.
3. Run `bash tests/test-sprint-1-regressions.sh`.
4. Run `bash tests/test-sprint-2-regressions.sh`.
5. If the Claude plugin behavior changed, bump `.claude-plugin/plugin.json`, push the changes, and refresh or reinstall from the GitHub marketplace.

See `CONTRIBUTING.md` for the contribution flow.

## Backward compatibility

The validator still understands older `TBD (reason: ...)` labels when reading legacy output.

New output must use the structured Sprint 1 label format.

## Authors

Created by Fabio Espindula and Bill Madeira at FEBA Capital.

Bill compiled the original PRD practices from common industry patterns that became the seed of this plugin. Fabio designed the current architecture, validation framework, quality gates, stack presets, and workflow.

## License

MIT. See [LICENSE](LICENSE).
