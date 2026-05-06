# PRD Generator

Plugin for Claude Code and Codex. Turns a freeform product idea into a validated, cross-doc-consistent PRD package, ready to hand to a coding agent.

## In 30 seconds

```
> /prd-generator
[skill] Language? > English
[skill] Brainstormed already? > Yes
[skill] Briefly describe what you want to build:
> Multi-tenant blog platform for portfolio companies. Each tenant
> gets isolated content, AI writers, publishing webhooks. Stack:
> Next.js 16 + Supabase. MVP needs auth, brief approval, content
> generation, scheduling.

[skill asks 6 high-leverage questions in 2 batches]
[skill confirms summary, you approve]

[skill] Generated 11 files in projects/blog-saas/.
        16 quality gates passed.
        8 items safe to implement.
        2 need decision before coding.
        3 deferred to v1.1.
```

Now any coding agent can read your PRD without making things up.

## What it generates

```
                    ┌─────────────────┐
                    │   Main PRD      │
                    │ {slug}-prd.md   │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        ↓                    ↓                    ↓
  ┌──────────┐         ┌──────────┐        ┌──────────┐
  │AGENTS.md │         │CLAUDE.md │        │  api-*   │
  │  rules   │         │ guardrail│        │ contracts│
  └──────────┘         └──────────┘        └──────────┘
        ↓                    ↓                    ↓
  ┌────────────────────────────────────────────────┐
  │  stack docs + DEVELOPMENT-WORKFLOW + README    │
  │       + CHANGELOG + service-boundaries         │
  └────────────────────────────────────────────────┘
```

Default output: `projects/{project-slug}/`.

## Why it exists

Most AI-generated PRDs fail in one of two ways:

```
Failure 1: sounds complete, hides decisions
Failure 2: five docs that contradict each other
```

This plugin pushes against both:

| Defense | How |
|---|---|
| Hidden uncertainty | Forces explicit `TBD { blocks_coding: yes/no }`, `Assumed { question, default, flip_cost }`, `Proposed { promote_when }` labels |
| Doc drift | 16 quality gates validate that PRD, endpoints, models, and RLS summaries agree |
| Workflow handwaving | Every workflow step must reference an exact endpoint or `UI only` |
| Stale runtime | Version Policy blocks EOL Node, Next.js, or framework defaults |
| Accidental activation | The skill only runs from `/prd-generator`, never from natural-language brainstorm |

## Install

In Claude Code, add the marketplace from `feba-capital/prd-generator` and install `prd-generator`. In Codex, the manifest is in `.codex-plugin/plugin.json` and the skill payload is the same `skills/prd-generator/` directory.

See [docs/skill-installation.md](docs/skill-installation.md) for the full path.

## Use

```
/prd-generator
```

The workflow:

1. Picks language (English, Portuguese, Spanish, Chinese, or Other)
2. Confirms idea is brainstormed (or hands off to a brainstorm skill)
3. Offers an optional 7-question MVP scope check
4. Reads your briefing, asks 2 to 4 high-leverage questions in batches
5. Confirms summary before generating
6. Writes the package into `projects/{slug}/`
7. Runs 16 quality gates and reports pass/fail per gate
8. Returns an Implementation Readiness summary

Works with any stack. Two presets bundled (`nextjs-supabase`, `yii2-mysql`); other stacks get ad-hoc generation that you can promote into a permanent preset later.

## What's in the box

| Path | Purpose |
|---|---|
| `commands/prd-generator.md` | The slash command entry |
| `skills/prd-generator/SKILL.md` | The workflow source of truth |
| `skills/prd-generator/interview/` | Step 0 to Step 6 prompts |
| `skills/prd-generator/templates/` | Base templates copied into every package |
| `skills/prd-generator/stack-presets/` | Reusable per-stack docs |
| `skills/prd-generator/scripts/validate-generated-docs.sh` | The 16-gate validator |
| `examples/wisercontent/` | Frozen reference snapshot |
| `tests/` | Pass/fail fixtures and three regression scripts |

## Quality gates (the 16)

| Group | Gate |
|---|---|
| Cross-doc | Workflow steps must point at endpoints that exist |
| Cross-doc | Reused endpoint anchors must carry distinct role/state qualifiers |
| Cross-doc | Endpoint access summaries must match RLS policy text |
| Cross-doc | Role claims must agree across PRD, endpoints, and RLS |
| Format | `TBD` / `Assumed` / `Proposed` must use classifier syntax |
| Format | No legacy `TBD (reason: ...)` in new output |
| Format | No em dash in prose |
| Format | No `Lorem`, `example.com`, `foo bar`, or `TODO` placeholders |
| Structure | All required sections present per file type |
| Structure | `Implementation Readiness` non-empty, with source citations |
| Structure | `Future Versions` and `Launch Dependencies` mutually exclusive |
| Structure | `Validation Plan` carries all four required fields |
| Structure | `Scope Decisions` items carry a non-empty reason |
| Hygiene | Runtime and framework versions current stable or pinned with reason |
| Hygiene | Non-admin UPDATE policies declare explicit transitions |
| Hygiene | Non-admin UPDATE policies enforce explicit columns |

## Develop on it

```bash
git clone https://github.com/feba-capital/prd-generator
cd prd-generator
bash tests/test-validate-generated-docs.sh
bash tests/test-sprint-1-regressions.sh
bash tests/test-sprint-2-regressions.sh
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full flow, including how to add a new stack preset or a new language.

## Authors

Created by Bill Madeira and Fabio Espindula at FEBA Capital.

Bill wrote the original PRD that became the seed of this plugin. Fabio reverse-engineered its structure into a reusable generator and built the validator, quality gates, stack presets, and multi-language workflow.

## License

MIT. See [LICENSE](LICENSE).
