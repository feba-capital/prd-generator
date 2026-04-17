# Framework Overview

This repository is the source of truth for the `prd-generator` Claude workflow.

## What lives here
- `.claude-plugin/` and `.codex-plugin/` contain plugin manifests kept aligned for local tooling compatibility.
- `commands/` contains explicit slash command entrypoints.
- `skills/prd-generator/` contains the formal workflow and reusable assets.
- `examples/` contains frozen reference output.
- `projects/` is the default destination for generated project packages.
- `tests/` contains validator fixtures and regression coverage for the plugin itself.

## What does not live here
- Live product code
- Auto-generated output in the root `docs/`
- Hidden LLM orchestration outside Claude
- Committed build artifacts under `dist/`
