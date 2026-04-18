# Step 1 -> Brainstorm-Readiness Check

Prompt:

> Is this idea already brainstormed, or still raw?

Options:

1. Already brainstormed, I know what I want
2. Still raw, I want to think it through first

If the user picks option 2:

- Offer a handoff to `product-management:brainstorm` or `product-management:product-brainstorming`.
- Exit cleanly with:

`I'll hand you off to /brainstorm. When you come back, re-run /prd-generator and pick "already brainstormed" at this step.`

- Do not persist hidden state.

Fallback when no brainstorm skill is available:

`No brainstorm skill available. Describe the idea in your own words and I will treat your description as the starting brief.`

PT-BR prompt reference:

> Essa ideia já foi brainstormada ou ainda está crua?
