
*MUST ALWAYS FOLLOW*

## Hallucination Guardrail (read this first)

If you see `TBD`, `Proposed`, or `Assumed` in any doc, STOP and ask Fabio before writing code. Do not invent to fill the gap.

- `TBD { blocks_coding: yes, reason: "..." }` -> unknown and blocks coding
- `TBD { blocks_coding: no, reason: "...", default: "..." }` -> unknown but can wait until deployment
- `Proposed { promote_when: "..." }` -> skill suggestion, not approved yet
- `Assumed { question: "...", default: "...", flip_cost: "low|medium|high" }` -> working assumption that still needs confirmation

Never promote a Proposed endpoint, model, integration, or role to Confirmed without explicit approval from Fabio.

---

## Reading Order

Always use @docs/AGENTS.md for all instructions.
Always use @docs/{{PROJECT_SLUG}}-prd-v{{VERSION}}.md for all product requirements.
Always use @docs/{{STACK_BEST_PRACTICES_FILE}} for all coding standards.
{{#MULTITENANT_YES_NO}}Always use @docs/{{STACK_SLUG|upper}}-TENANT-FILTERING.md for all tenant filtering rules.
{{/MULTITENANT_YES_NO}}
Always use @docs/DEVELOPMENT-WORKFLOW.md for all development workflow rules.
Always use @docs/api-docs.md for all API documentation.
Always use @docs/api-endpoints.md for all API endpoint request/response payloads.
Always use @docs/api-models.md for all API models.
Always use @docs/service-boundaries.md for all domain ownership and module responsibilities.

---

## Authority Hierarchy

When docs conflict:

1. Fabio (human) overrides everything
2. PRD overrides stack docs
3. Stack docs override code conventions
4. Never reconcile silently → ask Fabio

---

## Maintenance Rules

Document every endpoint with full Request/Response Payloads in @docs/api-endpoints.md. Keep `Confirmed` and `Proposed` sections separate.

Update CHANGELOG.md on every commit.

Update README.md on every major change.
