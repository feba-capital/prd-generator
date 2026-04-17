# Skill Installation

## Source of Truth
- Edit `skills/prd-generator/` and `commands/prd-generator.md` in this repository.
- Keep `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` aligned with the command and skill payload.

## Plugin Artifact
- Package the plugin locally under `dist/`, for example as `dist/prd-generator.plugin`.
- The repository keeps both Claude-style and Codex-style manifests so local tooling can choose the supported loader without changing the source tree.
- The `dist/` directory is local build output and should stay out of source control.

## Installation Flow
- Use Claude Code's plugin installation flow after the `.plugin` artifact is built.
- Local references confirm `/plugin install plugin@marketplace` and `/plugin marketplace add`.
- No local reference in this environment confirms a guaranteed `file://...plugin` install syntax, so treat direct file installs as build-dependent.

## Smoke Test
- After installation, start a fresh Claude session and invoke `/prd-generator` with a trivial briefing to confirm the formal workflow starts.
