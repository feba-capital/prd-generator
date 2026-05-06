# Contributing

Thanks for considering a contribution to `prd-generator`. This guide covers how to make changes, add stack presets, run tests, and open a pull request.

## Quick development loop

1. Fork the repo and clone your fork.
2. Edit files under `skills/prd-generator/`, `commands/`, `docs/`, `tests/`, or `examples/`.
3. Run all three test scripts before committing:
   ```bash
   bash tests/test-validate-generated-docs.sh
   bash tests/test-sprint-1-regressions.sh
   bash tests/test-sprint-2-regressions.sh
   ```
4. Open a pull request against `main`.

## Project structure

| Path | Purpose |
|---|---|
| `commands/prd-generator.md` | The `/prd-generator` slash command entry. |
| `skills/prd-generator/SKILL.md` | The full workflow, the source of truth for behavior. |
| `skills/prd-generator/interview/` | Step 0 to Step 6 prompts (language, brainstorm-readiness, MVP check, scope contract, briefing parser, question bank). |
| `skills/prd-generator/templates/` | The base templates copied into every generated PRD package. |
| `skills/prd-generator/stack-presets/` | Stack-specific best practices (Next.js / Supabase, Yii2 / MySQL). Adding more is welcome. |
| `skills/prd-generator/scripts/validate-generated-docs.sh` | The validator that enforces the 16 quality gates. |
| `tests/` | Pass and fail fixtures plus the three regression scripts. |
| `examples/wisercontent/` | Frozen reference snapshot of generated output. |

## Adding a new stack preset

1. Create `skills/prd-generator/stack-presets/{slug}/`.
2. Add a required `PRESET.md` (meta-information, default infrastructure, when-to-use).
3. Add `{STACK}-BEST-PRACTICES.md` (300 to 500 lines of opinionated coding standards).
4. Add `{STACK}-TENANT-FILTERING.md` or `{STACK}-PATTERNS.md` if the stack supports multi-tenant.
5. List the preset in `skills/prd-generator/stack-presets/README.md`.
6. Reference the preset in `skills/prd-generator/SKILL.md` under `## Stack Handling`.

The folder is a shortcut library, not a closed list. The skill accepts any stack and generates ad-hoc docs when no preset matches; promoting an ad-hoc set to a permanent preset goes through a manual review.

## Adding a new language

The skill supports multi-language output via translation at generation time. To add a language to the list shown in Step 0:

1. Add it to `skills/prd-generator/interview/language-question.md`.
2. Update the Step 0 options in `skills/prd-generator/SKILL.md`.
3. Add a regression fixture under `tests/quality/` to verify generation in that language.

Adding a language usually does not require new templates because translation happens in-flight. Only add a per-language fixture when the language has structural differences (right-to-left scripts, character sets that affect headings, etc.).

## Style rules for prose

- **Never use the em dash character in prose.** Use an arrow, comma, period, or rephrase. The character is allowed only inside code fences, inline backticks, regex examples, shell examples, or literal "what not to do" references.
- Direct, compact writing. No filler.
- No personal names hardcoded into templates or interview prompts. The skill should refer to "the owner" (the human authority over the PRD) or "the user" (the person running the skill).
- Keep technical terms in English even when generating output in another language: PRD, TBD, Proposed, Assumed, BIGINT, RLS, endpoint, schema, migration.

## Validator changes

If a contribution modifies the validator (`scripts/validate-generated-docs.sh`):

1. Add at least one matching fixture under `tests/quality/pass-{check}/` and `tests/quality/fail-{check}/`.
2. Wire the new check into `tests/test-validate-generated-docs.sh` if it is not auto-discovered.
3. Document the new check in `skills/prd-generator/SKILL.md` under `## Quality Check`.

## Commit conventions

Conventional Commits:

- `feat: add new stack preset for rails-postgres`
- `fix: correct cross-doc check for capitalized roles`
- `refactor: simplify language cascade in scope contract`
- `test: add fixture for chinese-language PRD output`
- `docs: clarify install path for codex marketplace`
- `chore: bump validator version to 1.4.0`

Keep commits focused. One logical change per commit.

## Pull request expectations

- All three test scripts pass locally.
- The em dash check passes (`grep` for em dash will fail the validator if found in prose).
- Any new fixture is paired with the corresponding template or skill change that produces it.
- The PR description states what was changed and what was tested.

## Reporting bugs

Open a GitHub issue with:

- the exact briefing or invocation that triggered the bug
- the expected output
- the actual output, including any validator messages
- the plugin version (`.claude-plugin/plugin.json` `version` field)

Thanks for contributing.
