# Override Example -> Product Requirements v1.0

## 1. Overview
Small team tool for coordinating office lunch orders.

### 1.1 Goals
- Let a team submit and confirm one shared lunch order.

### 1.2 Non-Goals
- No restaurant marketplace in v1.

## Scope Decisions
- Feature: dietary tags on each order item
  Reason: the team cannot use the MVP safely without allergy visibility
  Effect on v1: adds one required field to the order item form
- Feature: manual admin closeout before submitting the order
  Reason: the office manager needs one final review step before sending the order
  Effect on v1: adds a confirmation step before the final submit action

## 9. Resolved Decisions
1. The lunch-order flow stays internal and manual.

## Implementation Readiness

### Safe to implement now
- Dietary tags and manual closeout are confirmed by explicit scope decisions. (source: docs/sample-prd-v1.0.md:10)

### Needs explicit decision before coding
- None. (source: docs/sample-prd-v1.0.md:3)

### Needs decision before deployment (non-blocking for coding)
- None. (source: docs/sample-prd-v1.0.md:3)

### Intentionally deferred from this version
- None. (source: docs/sample-prd-v1.0.md:3)
