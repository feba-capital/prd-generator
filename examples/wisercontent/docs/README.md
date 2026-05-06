# WiserContent Content Platform API

API-first, multi-tenant content generation and publishing platform for Acme Inc portfolio companies.

## Features
- Multi-tenant Yii2 API with strict `tenant_id` scoping
- Component-based AI content generation with writer and reviser pipelines
- Automated scheduling, publishing webhooks, and audit logging
- Company profile context, Brand Strategist brief generation, and AlsoAsked ingestion

## Quick Start
- Read [wisercontent-prd-v2.md](wisercontent-prd-v2.md) for the product scope.
- Read [AGENTS.md](AGENTS.md) and [DEVELOPMENT-WORKFLOW.md](DEVELOPMENT-WORKFLOW.md) before changing code.
- Use the API reference docs to inspect models, controllers, endpoints, and payloads.

## Project Structure
- `wisercontent-prd-v2.md`: authoritative product requirements
- `AGENTS.md`: engineering and agent execution rules
- `DEVELOPMENT-WORKFLOW.md`: migrations, testing, linting, and delivery workflow
- `api-*.md`: API contracts, models, controllers, and endpoint documentation
- `YII2-*.md`: Yii2 coding and tenant isolation rules

## Development
- Treat this folder as a frozen example snapshot of generated project output.
- Keep docs internally consistent with the PRD when updating the example.
- Archive replaced legacy material outside the example snapshot instead of keeping conflicting references here.
