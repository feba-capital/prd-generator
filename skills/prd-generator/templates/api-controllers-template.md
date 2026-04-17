# DEPRECATED

This template has been replaced by `service-boundaries-template.md`.

**Why:** Controllers are implementation details (high hallucination risk when generated from a brainstorm). Service boundaries are architecture (low hallucination risk, captures ownership and coupling rules).

**Do not use this template for new projects.** The skill generates `service-boundaries.md` instead, which lives in `/docs/` of the target project.

If a project genuinely needs controller-level documentation, it should be written by a developer after the API is stable, not auto-generated from the PRD.
