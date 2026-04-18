# Bet Example -> Product Requirements v1.0

## 1. Overview
Lightweight tool for tracking short gym workouts with a betting-style MVP.

### 1.1 Goals
- Help one person log workouts quickly after each session.

### 1.2 Non-Goals
- No social sharing in v1.

## Scope Contract (v1)

### The Skateboard
- Primary user: solo gym user
- Core pain addressed: workouts are forgotten unless logging is immediate
- Viability statement: the logging flow is useful, but the product is still a bet
- Minimum flow: user records a workout, sees the weekly streak, and comes back later
- Success signal: the user logs multiple workouts in the same week
- Evidence base: intuition only, no user data yet

### Out of v1
- coaching plans

## Validation Plan
- Sample size: Assumed { question: "How many active users are enough for the first read?", default: "10 active users", flip_cost: "low" }
- Time window: Assumed { question: "How long should the first validation window run?", default: "14 days", flip_cost: "low" }
- Success metric: Assumed { question: "What outcome proves the workout logger is working?", default: "70 percent of users log 3 workouts in the window", flip_cost: "low" }
- Kill threshold: Assumed { question: "When do we stop and rethink the MVP?", default: "fewer than 3 users log 2 workouts in the window", flip_cost: "low" }

## 9. Resolved Decisions
1. The first version optimizes for fast solo logging.

## Implementation Readiness

### Safe to implement now
- The single-user workout logging flow is confirmed. (source: docs/sample-prd-v1.0.md:3)

### Needs explicit decision before coding
- None. (source: docs/sample-prd-v1.0.md:3)

### Needs decision before deployment (non-blocking for coding)
- Validation defaults can be refined before rollout. (source: docs/sample-prd-v1.0.md:19)

### Intentionally deferred from this version
- None. (source: docs/sample-prd-v1.0.md:3)
