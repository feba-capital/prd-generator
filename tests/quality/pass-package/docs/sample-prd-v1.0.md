# Sample Product: Product Requirements v1.0

## 1. Overview
Tiny internal snack tracker for one office.

### 1.1 Goals
- Let employees flag snacks that are running low.

### 1.2 Non-Goals
- No purchasing workflow in v1.0.

## 2. Core Workflows

**Flow: Flag running low**
1. User clicks the low-stock action on a snack card. `UI only, no API call`
2. User submits an optional note. `POST /api/v1/restock-requests`
3. User reviews the shared open queue. `GET /api/v1/restock-requests`
4. Requester cancels a mistaken request. `POST /api/v1/restock-requests/{id}/cancel`

## 3. Open Decisions
- Admin bootstrap: Assumed { question: "How is the first admin assigned?", default: "manual SQL migration", flip_cost: "medium" }
- Allowed email domain: TBD { blocks_coding: no, reason: "IT has not provided the company domain yet", default: "set SUPABASE_ALLOWED_EMAIL_DOMAIN before deployment" }
- Analytics dashboard: Proposed { promote_when: "defer to vNext unless the reviewer explicitly approves analytics in v1.1" }

## 8. Resolved Decisions
1. The app is single-tenant.
2. Authenticated users can view open restock requests, while requester or admin can also view non-open rows.

## Implementation Readiness

### Safe to implement now
- Open queue visibility is confirmed: authenticated users see open rows, requester or admin can also view non-open rows. (source: docs/sample-prd-v1.0.md:16)

### Needs explicit decision before coding
- Initial admin assignment still needs confirmation before implementation starts. (source: docs/sample-prd-v1.0.md:21)

### Needs decision before deployment (non-blocking for coding)
- The allowed email domain must be supplied before deployment. (source: docs/sample-prd-v1.0.md:22)

### Intentionally deferred from this version
- Analytics dashboard remains deferred. (source: docs/sample-prd-v1.0.md:23)
