# RLS Lint Failure: Product Requirements v1.0

## 1. Overview
Small snack tracker.

### 1.1 Goals
- Keep snacks stocked.

### 1.2 Non-Goals
- No purchasing.

## 2. Core Workflows

**Flow: Cancel request**
1. User cancels an open request. `POST /api/v1/restock-requests/{id}/cancel`

## 8. Resolved Decisions
1. Requester can cancel their own open row.

## Implementation Readiness

### Safe to implement now
- Cancel flow is documented. (source: docs/sample-prd-v1.0.md:12)

### Needs explicit decision before coding
- None. (source: docs/sample-prd-v1.0.md:12)

### Needs decision before deployment (non-blocking for coding)
- None. (source: docs/sample-prd-v1.0.md:12)

### Intentionally deferred from this version
- None. (source: docs/sample-prd-v1.0.md:12)
