# Workflow Anchor Pass: Product Requirements v1.0

## 1. Overview
Tiny workflow.

### 1.1 Goals
- Create an example entity.

### 1.2 Non-Goals
- No analytics.

## 2. Core Workflows

**Flow: Create example**
1. Member submits memory. `POST /api/v1/example`
2. Driver promotes the memory to shared scope. `POST /api/v1/example`

## 8. Resolved Decisions
1. Example creation uses one endpoint with role-specific steps.

## Implementation Readiness

### Safe to implement now
- Example flow is documented. (source: docs/sample-prd-v1.0.md:12)

### Needs explicit decision before coding
- None. (source: docs/sample-prd-v1.0.md:12)

### Needs decision before deployment (non-blocking for coding)
- None. (source: docs/sample-prd-v1.0.md:12)

### Intentionally deferred from this version
- None. (source: docs/sample-prd-v1.0.md:12)
