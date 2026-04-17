# Label Failure: Product Requirements v1.0

## 1. Overview
Small snack tracker.

### 1.1 Goals
- Keep snacks stocked.

### 1.2 Non-Goals
- No purchasing.

## 2. Core Workflows

**Flow: Flag running low**
1. User submits the form. `UI only, no API call`

## 3. Open Decisions
- Allowed email domain: TBD (reason: waiting for IT)
- Admin bootstrap: Assumed manual SQL migration.
- Analytics dashboard: Proposed.

## 8. Resolved Decisions
1. Single-tenant app.

## Implementation Readiness

### Safe to implement now
- Base workflow exists. (source: docs/sample-prd-v1.0.md:12)

### Needs explicit decision before coding
- Admin bootstrap still needs a decision. (source: docs/sample-prd-v1.0.md:16)

### Needs decision before deployment (non-blocking for coding)
- Allowed email domain is missing. (source: docs/sample-prd-v1.0.md:15)

### Intentionally deferred from this version
- Analytics dashboard is deferred. (source: docs/sample-prd-v1.0.md:17)
