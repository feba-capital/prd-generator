## Hallucination Guardrail
Use @docs/AGENTS.md for implementation rules and project conventions.
Use @docs/YII2-BEST-PRACTICES.md for coding standards.
Use @docs/YII2-TENANT-FILTERING.md for tenant isolation rules.
Use @docs/DEVELOPMENT-WORKFLOW.md for development workflow rules.
Use @docs/wisercontent-prd-v2.md for product requirements.
Use @docs/api-docs.md, @docs/api-endpoints.md, @docs/api-models.md, and @docs/api-controllers.md for API contracts.

## Reading Order
Start with @docs/wisercontent-prd-v2.md.
Then read @docs/AGENTS.md and @docs/DEVELOPMENT-WORKFLOW.md.
Read the API reference files before changing endpoints, models, or controllers.

## Authority Hierarchy
The PRD and AGENTS guide are the primary sources of truth for feature behavior.
Workflow and API reference docs must stay consistent with the PRD.

## Maintenance Rules
Document every endpoint with full request and response payloads in @docs/api-endpoints.md.
Update @CHANGELOG.md on every commit.
Update @README.md on every major change.
