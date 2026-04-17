# PRD Generator

Source repository for the `prd-generator` plugin.

This plugin provides a formal PRD workflow with explicit command entry, reusable stack presets, example output, and a validator that checks cross-doc consistency before a package is considered done.

## Repository Layout

- `.claude-plugin/` and `.codex-plugin/` contain plugin manifests kept in sync for local plugin tooling compatibility.
- `commands/` contains the explicit `/prd-generator` entrypoint.
- `skills/prd-generator/` contains the workflow, templates, presets, interview prompts, and validator.
- `docs/` contains maintenance and installation notes for the plugin itself.
- `examples/` contains frozen sample output used as a reference.
- `tests/` contains validator fixtures and Sprint 1 regression coverage.
- `projects/` is the default local output directory for generated PRD packages.

## Working on the Plugin

1. Edit files under `skills/prd-generator/`, `commands/`, `docs/`, or `tests/`.
2. Run `bash tests/test-validate-generated-docs.sh`.
3. Run `bash tests/test-sprint-1-regressions.sh`.
4. Rebuild the `.plugin` artifact locally when needed.

## Packaging

This repository is kept source-only for GitHub. Build artifacts belong in `dist/` locally and should not be committed.

## Notes

- Generated project output should not be committed to this repository unless it is an intentional frozen example under `examples/`.
- The validator supports reading older `TBD (reason: ...)` labels, but new output must use the structured Sprint 1 label format.
