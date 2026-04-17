# Skill Maintenance

## Routine Updates
1. Update the source files in this repository.
2. Rebuild the `.plugin` artifact.
3. Run the validator against example output.
4. Re-install or refresh the plugin in Claude Code.
5. Re-run the `/prd-generator` smoke test.

## Style Rule
- Prose must not use the em dash character.
- Em dash is allowed inside code fences, inline backticks, regex examples, shell examples, and literal "what not to do" references.
- HTML comments count as prose for this rule and should not contain em dash.

## Preset Promotion
- Ad-hoc stack docs start as project-local output.
- Promote them into `stack-presets/` only after review.
- Rebuild and reinstall the plugin after promotion.
