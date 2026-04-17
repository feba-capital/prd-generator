---
description: Run the formal prd-generator workflow explicitly for a PRD package request.
---

# /prd-generator

## Preflight
- Treat this command as an explicit request for the formal PRD workflow.
- Do not collapse into casual brainstorming.
- Do not ask the user to confirm whether they intended to run `/prd-generator`; the slash command invocation itself is the confirmation.
- Use the `prd-generator` skill assets under `skills/prd-generator/`.

## Plan
- Parse the user's freeform input.
- Run the discovery workflow.
- Confirm the summary.
- Generate the package into `projects/{project-slug}/` unless the user requested another path.

## Commands
- Use the `prd-generator` skill workflow as the single source of truth.
- Read `interview/`, `templates/`, `stack-presets/`, `references/`, and `scripts/` on demand.

## Verification
- Confirm the formal workflow started.
- Confirm the output path choice.
- Run post-generation validation.

## Summary
- **Action**: formal PRD workflow invoked
- **Status**: success | partial | failed
- **Details**: project slug, chosen stack, output path

## Next Steps
- Review the generated package
- Approve or revise `Proposed` items
- Promote any reviewed ad-hoc preset manually if needed
