---
name: prd-generator
description: Formal PRD generation workflow. Invoke explicitly via the /prd-generator slash command or when the user asks for the formal prd-generator workflow by name. Do not trigger on general brainstorm, planning conversations, or natural requests like "vamos pensar num PRD".
---

# PRD Generator Skill

Generate an execution-ready PRD package from a brainstorm briefing. Optimized for downstream code agents (Claude Code, Codex, Cursor). Its job is to reduce ambiguity, capture decisions, and produce docs engineering can use immediately.

---

## Version Policy

The skill must never recommend an end-of-life or outdated runtime / framework in generated docs. Rules:

1. At generation time, the skill verifies the current latest stable or LTS of every runtime and framework it plans to mention. Acceptable sources: the project's official release page, endoflife.date, or an equivalent official release tracker.
2. If the stack preset hardcodes a version that is more than 2 minor releases behind the current stable, the skill overrides the hardcoded value with the current one and notes this in the generated docs: `Updated to latest stable: {version}. Preset hardcode was {old}. See Version Policy.`
3. If web access is unavailable, the skill uses the hardcoded preset value and writes an `Assumed` entry at the end of the PRD: `Assumed { question: "Latest stable version of {runtime}?", default: "{preset_value}", flip_cost: "low" }`.
4. No version reference in generated docs is allowed to be unlabeled. Every version mention must either be `latest stable as of {YYYY-MM}` or a specific pinned version with a reason.
5. End-of-life dates known to be within 3 months of the generation date trigger a red flag in the Implementation Readiness section under `Needs decision before deployment`.

---

## Core Rule: Do Not Invent Certainty

Anything not explicitly confirmed by the user or clearly implied by the briefing must be labeled:

- `TBD { blocks_coding: yes, reason: "..." }`
- `TBD { blocks_coding: no, reason: "...", default: "..." }`
- `Assumed { question: "...", default: "...", flip_cost: "low|medium|high" }`
- `Proposed { promote_when: "..." }`

Never present an unconfirmed integration, endpoint, role, entity, auth flow, infra detail, retention policy, or deployment target as final. This is the #1 quality guardrail.

Never emit bare `TBD`, `Assumed`, or `Proposed` labels in new output.

Legacy `TBD (reason: ...)` may still exist in older generated packages. Do not emit that legacy syntax in new output.

---

## Output Location

Default output root: `<repo-root>/projects/{project-slug}/`.

If the user explicitly requests another path, use that path instead and report it back.

Fallback order if that path is unavailable:

1. current repository `projects/` folder
2. current workspace root
3. return the package inline in chat as structured markdown blocks

Never fail silently because of filesystem assumptions. Report the final path used.

---

## Operating Modes

### `full-package` (default)
Generate the complete doc package when enough information is confirmed.

### `fast-draft`
Use when the user says "just generate it" or wants speed over completeness. Generate anyway, but mark every unresolved piece with the classified `TBD`, `Proposed`, or `Assumed` forms above.

### `update-existing`
Use when revising an existing PRD. Preserve confirmed decisions unless the user explicitly changes them.

---

## Required Inputs Before Full Generation

Confirm these 9 before generating a strong full package:

1. Project name
2. Core problem / objective
3. Target users
4. Project type
5. Technical stack
6. Authentication approach
7. Multi-tenant = yes/no
8. MVP scope
9. Non-goals / what stays out of v1.0

If the user refuses to answer, switch to `fast-draft` and mark gaps clearly.

---

## Interaction Workflow

This workflow only runs after explicit invocation through `/prd-generator` or a direct request for the formal `prd-generator` workflow.

### Step 0. Language selection
Ask first, before any other interaction, using `interview/language-question.md`.

Options:

1. `English` (default)
2. `Brazilian Portuguese`
3. `Spanish`
4. `Chinese (Simplified)`
5. `Other, specify`

The chosen language applies to:

- the conversation
- the generated docs
- any handoff message to another skill

For all listed languages, translate user-facing PRD section headings, intros, and prose into the chosen language. Keep technical terms in English (PRD, TBD, Proposed, Assumed, BIGINT, RLS, endpoint).

If the user picks "Other, specify", proceed with a quality caveat and do not block.

### Step 1. Brainstorm-readiness check
Ask `Is this idea already brainstormed, or still raw?` using `interview/brainstorm-readiness.md`.

Options:

1. `Already brainstormed` -> proceed to Step 2
2. `Still raw` -> offer handoff to `product-management:brainstorm` or `product-management:product-brainstorming`

If the brainstorm skill is unavailable, fall back to plain-text capture:

`No brainstorm skill available. Describe the idea in your own words and I will treat your description as the starting brief.`

No hidden state is persisted across skills. If the user leaves for brainstorming, they must re-run `/prd-generator`.

### Step 2. Optional MVP check
Offer the MVP check using `interview/mvp-check.md`:

`Want to run a quick MVP check? 7 questions, helps avoid a bloated v1. Skip if you already thought through the scope.`

Options:

1. `Run the check`
2. `Skip, I already scoped it`

If the user skips, proceed directly to Step 3 with no extra friction.

Fast path rule: the added interaction for users who skip Step 1 handoff and skip Step 2 must stay under 30 seconds.

If the user runs it, ask the 7 questions in order with 2 opinionated options plus 1 free-text fallback. The signal mappings from `interview/mvp-check.md` are mandatory:

- Q3 option 3 -> skip `Future Versions`, add `Launch Dependencies`
- Q7 option 3 -> add `Validation Plan`

After the 7 questions, assemble the scope contract from `interview/scope-contract.md`.

### Step 2.5. Optional scope contract export
If Step 2 ran, ask:

`Want me to save this scope contract as a standalone file? Useful to share with stakeholders without sending the full PRD.`

Options:

1. `Yes, save to projects/{slug}/scope-contract.md`
2. `No, keep it inside the PRD only`

The saved scope contract must be readable standalone in under 2 minutes by a non-technical stakeholder.

### Override pattern
After presenting the scope contract, ask:

`This is the recommended skateboard. You can:
1. Proceed with this skateboard for the PRD.
2. Add features to v1 that you consider essential even if they fall outside the recommendation. Which?
3. Rewrite the skateboard from scratch.`

Behavior:

- Option 1 -> proceed with the recommended skateboard
- Option 2 -> capture each added feature plus one follow-up `Why is this essential for v1?`; log each pair in `## Scope Decisions`
- Option 3 -> capture the rewritten v1 scope in free text; honor it; log that the recommendation was rejected in `## Scope Decisions`

The recommendation is advisory. The user's override is always honored. Do not argue or force the recommendation back in.

### Step 3. Read the scoped briefing
Extract what is already known from the freeform briefing. Do not re-ask anything the briefing already answers. See `interview/briefing-parser.md`.

If Step 2 ran, prefix the interview intro with:

`Now I will ask about the skateboard we just defined, not the full vision.`

### Step 4. Build internal decision checklist
Classify these 14 fields as `confirmed`, `partial`, or `missing`:

1. Project name
2. Problem / objective
3. Target users
4. Project type
5. Stack (if hybrid: frontend stack + backend stack separately)
6. Auth
7. Multi-tenant
8. Roles / permissions
9. Core entities
10. Integrations
11. MVP scope
12. Non-goals
13. Deploy / infra
14. Observability / ops

### Step 5. Ask only high-leverage questions
Ask in batches of 2 to 4 only after the formal workflow has been explicitly invoked. Rules:

- Prioritize architecture-changing questions (multi-tenant yes/no, auth method, project type)
- Never ask what the briefing already answered
- Do not ask UI or polish details
- For hybrid stacks, ask the hybrid batch in `interview/questions.md` (repo split + contract ownership)

### Step 6. Confirm summary before generating
Show the user a short summary:

- Name
- Project type
- Stack
- Auth
- Multi-tenant
- MVP core (3 to 5 bullets)
- Non-goals (2 to 3 bullets)

Ask for approval. Adjust if needed, re-confirm.

## Behavior Guards

### Existing Output Directory

If `projects/{project-slug}/` already exists, do not overwrite it silently.

Ask whether to:
1. overwrite the existing directory
2. generate into a new slug
3. treat the request as an update to the existing project

### Skip Interview

If the user explicitly wants to skip the interview, warn that the package will contain more `TBD { ... }` and `Assumed { ... }` entries and confirm before proceeding.

---

## Project Types and Required Documents

### Always generate (every project type)

- `CLAUDE.md` (root)
- `README.md` (root)
- `CHANGELOG.md` (root)
- `docs/{project-slug}-prd-v1.0.md`
- `docs/AGENTS.md`
- `docs/DEVELOPMENT-WORKFLOW.md`
- stack best-practices doc
- tenant/patterns doc (only if multi-tenant = yes)

### Additional docs by project type

| Project type | Additional docs in `/docs/` |
|---|---|
| Fullstack web app | `api-docs.md`, `api-endpoints.md`, `api-models.md`, `service-boundaries.md` |
| Backend API only | `api-docs.md`, `api-endpoints.md`, `api-models.md`, `service-boundaries.md` |
| Mobile app (owned backend) | `screens.md`, `state-model.md`, `api-docs.md`, `api-endpoints.md`, `api-models.md`, `service-boundaries.md` |
| Mobile app (third-party APIs only) | `screens.md`, `state-model.md`, `integrations.md` |
| Browser extension | `manifest-spec.md`, `content-scripts.md` (if used), `background-worker.md` (if used) |
| CLI tool / script | `commands.md` |
| Desktop app | `screens.md`, `state-model.md`, api-* docs (only if client-server) |

For unknown project types, generate the base package first and add only clearly relevant docs.

Note: `api-controllers.md` from older versions is replaced by `service-boundaries.md`. Controllers are implementation (high invention risk). Boundaries are architecture (low invention risk).

---

## Stack Handling (open-ended)

Stack support is NOT limited to presets. Any stack is accepted.

### Exact preset match
Copy preset files from `stack-presets/{slug}/` into project `/docs/`.

### Partial preset match
Adapt the closest preset. Mark the adjustment as `Assumed { question: "...", default: "...", flip_cost: "low|medium|high" }` in generated docs.
Example: preset says `Next.js 16 (latest stable as of 2026-04)`, but the live stable release has advanced since the preset was last refreshed -> adapt and label.

### New stack (ad-hoc generation)
Generate stack docs from scratch. Rules:

- **Max ~150 lines per doc on first pass.** Don't over-engineer.
- Cover only the essentials: project structure, naming, data layer, testing, 3 to 5 anti-patterns.
- Mark at top of the file: `<!-- v0.1 ad-hoc draft. Expand before shipping code. -->`
- Save it first as project-local output. Promote it into `stack-presets/{new-slug}/` only after manual review and a skill sync.

Expansion to a full 300-500 line preset is a separate command, not part of the initial PRD generation. This protects PRD quality from being diluted by preset work.

### Hybrid stacks (frontend stack ≠ backend stack)

When frontend and backend are clearly different stacks, generate separately:

- `FRONTEND-{STACK}-BEST-PRACTICES.md`
- `BACKEND-{STACK}-BEST-PRACTICES.md`
- `CONTRACTS.md` → where the API contract lives and who owns it

Authority rules for hybrid (document these in the PRD under "Architecture Split"):

- Backend owns: schema, auth, API contract, error envelope
- Frontend owns: UI state, routing, client-side validation
- PRD section "Architecture Split" makes this explicit

Required interview questions for hybrid (see `interview/questions.md` Batch Hybrid):

- Same repo or separate repos?
- Who defines the API contract (backend-first, contract-first, frontend-driven)?

---

## Output Rules

### Language
Use the language chosen in Step 0 for the conversation and generated docs.

- English remains the authoring default.
- For Brazilian Portuguese, Spanish, and Chinese (Simplified): translate user-facing PRD section headings, intros, and prose into that language. Keep technical terms in English (PRD, TBD, Proposed, Assumed, BIGINT, RLS, endpoint, schema, migration).
- For any other language ("Other, specify"): translate on best effort with a quality caveat. Do not block generation.
- Templates are written in English. Translation happens at generation time, not via separate templates per language. This keeps templates maintainable and supports any future language without template changes.

### Formatting
- **Never use em dash in prose.** Use arrow, comma, period, colon, or rephrase. The punctuation itself is allowed only inside code fences, inline backticks, regex examples, shell examples, or literal "what not to do" references.
- Direct, compact writing
- Use numbered lists for decisions
- Use classified `TBD` / `Proposed` / `Assumed` labels explicitly

### IDs
Default to large integer IDs (BIGINT UNSIGNED for MySQL, BIGSERIAL for Postgres). Never UUIDs unless the user explicitly asks.

### Versioning
First PRD is always `v1.0`. Filename: `{project-slug}-prd-v1.0.md`.

### Non-goals
Mandatory. If the briefing doesn't include them, ask. If the user refuses, create a `Proposed Non-Goals` section.

### Resolved Decisions
End the main PRD with a numbered `Resolved Decisions` section. Every confirmed choice from the interview appears here.

### Implementation Readiness Synthesis
End the main PRD with `## Implementation Readiness`.

Populate it after all other docs are written by scanning the generated package:

- `Safe to implement now` → confirmed items with no blocking dependency
- `Needs explicit decision before coding` → every `TBD { blocks_coding: yes, ... }` plus every `Assumed { ... flip_cost: "medium|high" }`
- `Needs decision before deployment (non-blocking for coding)` → every `TBD { blocks_coding: no, ... }`
- `Intentionally deferred from this version` → every `Proposed { promote_when: "..." }` that explicitly defers to vNext

Every bullet in this section must cite a concrete source file and line in the format `(source: docs/file.md:42)`.

---

## File Quality Requirements

## Step 4 Conditional Sections

When Step 2 ran, Step 4 generation must emit the following sections conditionally:

- `## Future Versions` -> only when Step 2 ran and Q3 was not option 3
- `## Launch Dependencies` -> only when Step 2 ran and Q3 was option 3
- `## Validation Plan` -> only when Step 2 ran and Q7 was option 3
- `## Scope Decisions` -> only when Step 2 ran and the override pattern used option 2 or 3

Rules:

- `Future Versions` and `Launch Dependencies` are mutually exclusive. Never emit both.
- Every item in `Future Versions` must use `Proposed { promote_when: "..." }`.
- Every item in `Scope Decisions` must include a non-empty `reason`.
- `Validation Plan` must include all four fields: sample size, time window, success metric, kill threshold.
- If Step 2 did not run, none of the four sections are required.

### Main PRD must include
- problem
- target users
- success outcome
- MVP scope
- non-goals
- core user flows (min 3, each with actor + trigger + outcome)
- core workflows where every numbered step ends with either an exact endpoint reference in backticks or `UI only, no API call`
- core entities (min 3, each with 2 to 4 key fields)
- permissions model (if relevant)
- integrations (split into `Confirmed` + `Proposed` sections)
- constraints
- risks
- unresolved questions
- resolved decisions
- implementation readiness

### AGENTS.md must include
- reading order (which doc to open first, second, third)
- source-of-truth precedence (PRD > stack docs > code conventions)
- what to do if docs conflict (ask the owner, never reconcile silently)
- how to treat `TBD`, `Proposed`, and `Assumed` (stop and ask the owner, never fill in)

### CLAUDE.md must include
- top-line rule: "If you see TBD, Proposed, or Assumed in any doc, STOP and ask the owner. Do not invent to fill the gap."
- pointers to AGENTS.md, PRD, stack docs, API docs
- update rules for CHANGELOG and README

### DEVELOPMENT-WORKFLOW.md must include
- local setup
- environment variables
- migrations / schema changes
- test commands
- lint/build commands
- branch/commit conventions
- CI expectations
- deploy expectations if known

### api-docs.md must include
- auth model
- request/response envelope
- error format
- pagination (if relevant)
- rate limiting (if relevant)
- idempotency (if relevant)

### api-endpoints.md must separate
- `## Confirmed Endpoints` (derived from interview + explicit user flows)
- `## Proposed Endpoints` (skill's inference, awaiting the owner's approval)

Never mix these two sections. Never promote Proposed → Confirmed without the owner's explicit approval.

For every endpoint, include:

- exact heading in the form `METHOD /api/vX/...`
- `Table`
- `Governing policy` (exact policy name, or `n/a (service-layer auth)` when no table RLS applies)
- `Access summary`
- `Field contract` listing every entity field used in the request/response bodies

### api-models.md must separate
- `## Confirmed Models` (from core entities in PRD)
- `## Proposed Models` (skill's inference)

It must also include `## RLS Policy Summary`.

For each policy summary, use this exact structure:

- `### Policy \`policy_name\``
- `Table`
- `Operation`
- `Access summary`
- `USING` when present
- `WITH CHECK` when present
- `Enforced by` when a trigger/helper constrains non-admin updates

### service-boundaries.md must include
- domain modules / bounded contexts
- ownership boundaries (who owns what data)
- responsibilities per service / module
- coupling to avoid (anti-patterns)

---

## Practical Generation Order

1. Run Step 0 language selection.
2. Run Step 1 brainstorm-readiness check.
3. Offer Step 2 MVP check. If accepted, assemble the scope contract, run the override pattern, and offer Step 2.5 export.
4. Confirm summary with the user (Step 6 of the interaction workflow).
5. Create folder `/projects/{project-slug}/` and its `/docs/` subfolder.
6. Generate the main PRD (densest file, anchor for everything else).
7. If Step 2 ran, embed `## Scope Contract (v1)` in the main PRD and save `scope-contract.md` when Step 2.5 requested it.
8. Generate `AGENTS.md`.
9. Generate `DEVELOPMENT-WORKFLOW.md`.
10. Generate project-type-specific docs (`api-*`, `screens`, etc.).
11. Copy or generate stack docs.
12. Generate root files: `README.md`, `CHANGELOG.md`, `CLAUDE.md`.
13. Emit conditional PRD sections from Step 2 signals: `Future Versions`, `Launch Dependencies`, `Validation Plan`, `Scope Decisions`.
14. Build `## Implementation Readiness` from the actual labels present in the generated package, with source file + line citations.
15. Resolve runtime and framework versions against the Version Policy before finalizing stack docs or setup steps.
16. Run `PRD_GENERATOR_ALLOW_LEGACY_LABELS=0 bash skills/prd-generator/scripts/validate-generated-docs.sh <project-root>`.
17. Run a Cross-Doc Consistency Pass. If any mismatch remains, stop and list every mismatch before asking the user to waive anything.
18. Report to the user.

---

## Quality Check (before declaring done)

Run automatically before returning to the user. Fail loudly on each issue found.

1. **Em dash scan.** Check for em dashes in prose across all generated files. Ignore code fences and inline backticks.
2. **Placeholder scan.** Flag `Lorem`, `example.com`, `foo bar`, and `TODO`.
3. **Empty section scan.** Flag any section header followed by another header without content.
4. **TBD classifier scan.** Every `TBD` must use the new classifier syntax.
5. **Assumed / Proposed shape scan.** Every `Assumed` must have `question` + `default` + `flip_cost`. Every `Proposed` must have `promote_when`.
6. **Cross-doc RLS scan.** `api-models.md` RLS summaries must match `SUPABASE-PATTERNS.md` policy text exactly.
7. **Cross-doc access-control scan.** `api-endpoints.md` access summaries must match the governing policy summaries in `api-models.md`.
8. **Workflow-to-endpoint scan.** Every PRD workflow step must reference an endpoint or `UI only`.
9. **RLS lint scan.** Every non-admin UPDATE policy must have explicit transition text and explicit column/transition enforcement.
10. **Implementation Readiness scan.** `## Implementation Readiness` must exist, all subsections must be non-empty, and every bullet must cite a source file + line.
11. **Access-control consistency scan.** Role claims in the PRD must agree with the endpoint access block and the underlying RLS policy for the same action.
12. **Workflow-anchor uniqueness scan.** Reused endpoint anchors across workflow steps must carry distinct role, state, or anchor qualifiers. Duplicate indistinguishable anchors fail.
13. **Version currency scan.** Runtime and framework mentions must use current stable or LTS wording, or be pinned with an explicit reason. Bare stale references fail this check.
14. **Mutually exclusive sections scan.** `Future Versions` and `Launch Dependencies` must never both appear in the same PRD.
15. **Scope Decisions justification scan.** Every item under `Scope Decisions` must include a non-empty `reason`.
16. **Validation Plan completeness scan.** If `Validation Plan` exists, sample size, time window, success metric, and kill threshold must all be present.

Do not declare the task complete until all 16 checks pass or the user explicitly waives a specific failing item.

---

## Final Response Format

When done, return:

1. **Files created** (absolute paths, grouped by folder)
2. **Final output path used**
3. **Quality check results** (pass/fail per check)
4. **Unresolved items**
   - blocking decisions first
   - non-blocking deployment decisions second
   - deferred proposals last
5. **Next best step** (pick one: review scope, approve proposed integrations, expand stack preset, draft schema, draft migrations, start building)

---

## Failure Handling

### Briefing too vague
Do not generate a confident PRD. Ask the minimum high-leverage questions first.

### User says "just generate it"
Use `fast-draft`. Be explicit about every `Proposed` and `Assumed`.

### Stack unfamiliar
Generate product docs first. Keep stack docs ~150 lines ad-hoc and mark as `v0.1 draft`. Offer expansion as a separate step.

### Architecture still fluid
Prefer `service-boundaries.md` over controller-level detail. Use `Proposed Endpoints` section liberally rather than inventing confirmed endpoints.

---

## Reference Files

- `interview/briefing-parser.md` → how to parse freeform briefing into 14-field checklist
- `interview/questions.md` → question bank, batched, including hybrid-stack batch
- `templates/*` → base templates for each output file
- `stack-presets/*` → shortcut library (not a closed list)

Reference files guide quality. They do not override confirmed user decisions.

---

## Operating Standard

Produce documentation that is useful for real execution, not impressive-looking output. Bias toward:

- clarity
- practical scope
- explicit tradeoffs
- decision capture
- low hallucination
- docs developers can actually use

If in doubt: use the classified `TBD { ... }` syntax and ask. Never fill a gap with fiction.
