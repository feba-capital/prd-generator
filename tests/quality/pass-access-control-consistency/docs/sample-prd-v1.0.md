# Access Control Pass: Product Requirements v1.0

## 1. Overview
Tiny approval flow.

### 1.1 Goals
- Let the BU approval group approve a memory.

### 1.2 Non-Goals
- No analytics.

## 2. Core Workflows

**Flow: Approve memory**
1. Driver, owner, or copilot approves the memory. `POST /api/v1/memories/{id}/approvals`

## 8. Resolved Decisions
1. Driver, owner, or copilot approves memory in v1.0.

## Implementation Readiness

### Safe to implement now
- Approval flow is documented. (source: docs/sample-prd-v1.0.md:12)

### Needs explicit decision before coding
- None. (source: docs/sample-prd-v1.0.md:12)

### Needs decision before deployment (non-blocking for coding)
- None. (source: docs/sample-prd-v1.0.md:12)

### Intentionally deferred from this version
- None. (source: docs/sample-prd-v1.0.md:12)
