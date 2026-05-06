# Skill Installation

## Source of Truth
- Edit `skills/prd-generator/` and `commands/prd-generator.md` in this repository.
- Keep `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, and `.codex-plugin/plugin.json` aligned with the command and skill payload.
- When the Claude plugin behavior changes, bump the version in `.claude-plugin/plugin.json` before asking users to refresh or reinstall.

## Recommended Installation
- The supported distribution path for Claude is the GitHub marketplace defined in `.claude-plugin/marketplace.json`.
- Publish changes to the repository, then add or refresh the marketplace from `feba-capital/prd-generator`.
- Install `prd-generator` from the `prd-generator` marketplace.

## Local Packaging
- Local packaged artifacts are optional and exist only for development, testing, or manual distribution.
- If a local build is produced, treat it as a convenience output rather than the source of truth.
- Do not point the Claude marketplace configuration at a local build directory when validating the GitHub install path.

## Smoke Test
- After installation or marketplace refresh, start a fresh Claude session and invoke `/prd-generator` with a trivial briefing to confirm the formal workflow starts.
- If Claude still loads an older version, remove the stale marketplace entry and cached plugin copy before reinstalling from GitHub.
