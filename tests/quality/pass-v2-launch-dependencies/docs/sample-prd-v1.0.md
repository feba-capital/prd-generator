# Bundled Example -> Product Requirements v1.0

## 1. Overview
Tiny internal visitor flow that only works if check-in and badge printing ship together.

### 1.1 Goals
- Let reception check in visitors and print a badge in the same flow.

### 1.2 Non-Goals
- No analytics dashboard in v1.

## Scope Contract (v1)

### The Skateboard
- Primary user: receptionist
- Core pain addressed: front desk loses time between a spreadsheet and a badge printer
- Viability statement: the value only exists when registration and badge printing ship together
- Minimum flow: receptionist registers the visitor, prints the badge, and sees the current queue
- Success signal: check-in completes in one desk flow
- Evidence base: direct operational pain from the front desk team

### Out of v1
- visitor analytics

## Launch Dependencies
- Visitor registration form and badge printing must ship together in v1.
- Queue visibility must ship with the same release so reception can verify the current visitor list.

## 9. Resolved Decisions
1. The visitor desk tool launches as one bundled flow.

## Implementation Readiness

### Safe to implement now
- Registration, badge printing, and queue visibility ship together as one v1 unit. (source: docs/sample-prd-v1.0.md:19)

### Needs explicit decision before coding
- None. (source: docs/sample-prd-v1.0.md:3)

### Needs decision before deployment (non-blocking for coding)
- None. (source: docs/sample-prd-v1.0.md:3)

### Intentionally deferred from this version
- None. (source: docs/sample-prd-v1.0.md:3)
