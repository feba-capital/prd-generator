---
description: Run the formal prd-generator workflow explicitly for a PRD package request.
---

# /prd-generator

## Preflight
- Treat this command as an explicit request for the formal PRD workflow.
- Do not collapse into casual brainstorming.
- Do not ask the user to confirm whether they intended to run `/prd-generator`; the slash command invocation itself is the confirmation.
- Use the `prd-generator` skill assets under `skills/prd-generator/`.
- Start with Step 0 language selection, then Step 1 brainstorm-readiness, then Step 2 optional MVP check.

## Plan
- Parse the user's freeform input.
- Run Step 0 language selection.
- Run Step 1 brainstorm-readiness. If the user wants brainstorming first, hand off cleanly to `/brainstorm` when available or fall back to plain-text idea capture.
- Offer Step 2 optional MVP check. If skipped, continue without friction. If accepted, assemble the scope contract, run the override pattern, and offer the optional scope-contract export.
- Run the discovery workflow for the chosen scope.
- Confirm the summary.
- Generate the package into `projects/{project-slug}/` unless the user requested another path.

## Commands
- Use the `prd-generator` skill workflow as the single source of truth.
- Read `interview/`, `templates/`, `stack-presets/`, `references/`, and `scripts/` on demand.

## Verification
- Confirm the formal workflow started.
- Confirm the chosen language.
- Confirm the output path choice.
- If Step 2 ran, confirm whether the scope contract stayed inside the PRD or was also saved as a standalone file.
- Run post-generation validation.

## Summary
- **Action**: formal PRD workflow invoked
- **Status**: success | partial | failed
- **Details**: project slug, chosen stack, output path

## Next Steps
- Review the generated package
- Approve or revise `Proposed` items
- Promote any reviewed ad-hoc preset manually if needed
