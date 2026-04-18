# Gym Workouts -> Product Requirements v1.0

## 1. Overview
Tiny tracker for logging gym workouts right after each session.

### 1.1 Goals
- Let one user log workouts quickly and see a simple streak.

### 1.2 Non-Goals
- No coaching plans in v1.

## Scope Contract (v1)

### The Skateboard
- Primary user: solo gym user
- Core pain addressed: workouts are forgotten unless logging is immediate
- Viability statement: the standalone logging flow is useful on its own
- Minimum flow: user records a workout and sees the weekly streak in the same session
- Success signal: the user logs three workouts in one week
- Evidence base: partial, based on a strong personal hypothesis

### Out of v1
- coaching plans
- social sharing

## Future Versions
- Scooter -> add templated routines. `Proposed { promote_when: "defer to vNext unless repeat users ask for saved routines after 2 weeks" }`

## Validation Plan
- Sample size: Assumed { question: "How many active users are enough for the first read?", default: "10 active users", flip_cost: "low" }
- Time window: Assumed { question: "How long should the first validation window run?", default: "14 days", flip_cost: "low" }
- Success metric: Assumed { question: "What outcome proves the workout logger is working?", default: "70 percent of active users log 3 workouts in the window", flip_cost: "low" }
- Kill threshold: Assumed { question: "When do we stop and rethink the MVP?", default: "fewer than 3 users log 2 workouts in the window", flip_cost: "low" }

## 9. Resolved Decisions
1. The first release focuses on solo workout logging with no social features.

## Implementation Readiness

### Safe to implement now
- Solo workout logging and weekly streak visibility are confirmed for v1. (source: docs/gym-workouts-prd-v1.0.md:3)

### Needs explicit decision before coding
- None. (source: docs/gym-workouts-prd-v1.0.md:3)

### Needs decision before deployment (non-blocking for coding)
- Validation defaults can be tuned before rollout. (source: docs/gym-workouts-prd-v1.0.md:24)

### Intentionally deferred from this version
- Saved routines stay deferred for a later version. (source: docs/gym-workouts-prd-v1.0.md:21)
