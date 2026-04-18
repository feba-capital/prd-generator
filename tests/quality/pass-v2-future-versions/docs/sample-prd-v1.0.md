# Scope Example -> Product Requirements v1.0

## 1. Overview
Tiny workflow for tracking shared vehicle keys.

### 1.1 Goals
- Let the office see who currently has a key.

### 1.2 Non-Goals
- No hardware integrations in v1.

## Scope Contract (v1)

### The Skateboard
- Primary user: office assistant
- Core pain addressed: keys disappear without an audit trail
- Viability statement: the standalone check-in and check-out flow is useful on its own
- Minimum flow: user checks out a key, returns it later, and the current holder stays visible
- Success signal: the team stops asking who has each key
- Evidence base: clear internal pain reported by the office team

### Out of v1
- hardware lockers

## Future Versions
- Scooter -> add overdue reminders. `Proposed { promote_when: "defer to vNext unless the office team confirms reminders after 2 weeks of usage" }`

## 9. Resolved Decisions
1. The key register stays single-tenant and internal.

## Implementation Readiness

### Safe to implement now
- The standalone check-in and check-out flow is confirmed. (source: docs/sample-prd-v1.0.md:3)

### Needs explicit decision before coding
- None. (source: docs/sample-prd-v1.0.md:3)

### Needs decision before deployment (non-blocking for coding)
- None. (source: docs/sample-prd-v1.0.md:3)

### Intentionally deferred from this version
- Reminder automation stays deferred. (source: docs/sample-prd-v1.0.md:19)
