<!--
Translation rule:
This template is authored in English. When the language chosen in Step 0 is not
English (PT-BR, Spanish, Chinese, or Other), translate user-facing section
headings, intros, and prose into the chosen language at generation time. Keep
technical terms in English (PRD, TBD, Proposed, Assumed, BIGINT, RLS, endpoint,
schema, migration). Keep template placeholders ({{...}}) unchanged.
-->

# {{PROJECT_NAME}} -> Product Requirements v{{VERSION}}

**Owner:** {{OWNER}}
**Stack:** {{STACK_DESCRIPTION}}
**Architecture:** API-first{{#MULTITENANT_YES_NO}}, multi-tenant, single-database{{/MULTITENANT_YES_NO}}
**Status:** Draft v{{VERSION}}

---

## 1. Overview

{{PROJECT_TAGLINE}}

### 1.1 Goals
- Primary business objective for this product
- Secondary objective
- Tertiary objective

### 1.2 Non-Goals (v{{VERSION}})
- Feature explicitly out of scope
- Known limitation deferred to v{{VERSION|increment}}
- Dependency or integration explicitly not supported in v{{VERSION}}

---

{{#STEP2_RAN}}
## Scope Contract (v1)

### The Skateboard
- {{SCOPE_CONTRACT_PRIMARY_USER}}
- {{SCOPE_CONTRACT_CORE_PAIN}}
- {{SCOPE_CONTRACT_VIABILITY}}
- {{SCOPE_CONTRACT_MINIMUM_FLOW}}
- {{SCOPE_CONTRACT_SUCCESS_SIGNAL}}
- {{SCOPE_CONTRACT_EVIDENCE}}

### Out of v1
{{#SCOPE_CONTRACT_OUT_OF_V1}}
- {{.}}
{{/SCOPE_CONTRACT_OUT_OF_V1}}

---
{{/STEP2_RAN}}

{{#MULTITENANT_YES_NO}}
## 2. Tenancy & Users

### 2.1 Isolation Model
- **Single database**, row-level scoping via `tenant_id` on every tenant-owned table.
- **All IDs are `BIGINT UNSIGNED`.** No string IDs, no UUIDs.
- Global middleware enforces tenant scope on every authenticated request; queries without a `tenant_id` filter are rejected.

### 2.2 Users & Roles

**Platform-level role:**

| Role | Permissions |
|---|---|
| PlatformAdmin | Super-admin, manages all tenants and platform config. Not scoped to a single tenant. |

**Tenant-level roles:**

| Role | Permissions |
|---|---|
| Owner | Full tenant control including user management, config, approvals |
| Admin | Manage resources, approve content, manage team members |
| Editor | Create/edit resources, trigger workflows, approve content |
| Viewer | Read-only access |

### 2.3 Cross-Tenant Users
- A single user account may belong to multiple tenants via a join table carrying per-membership role.
- JWT access tokens embed an **active `tenant_id`**; switching tenants issues a new token.
- All authorization checks use the active tenant from the token.
- **PlatformAdmin** is a platform-level flag (not per-tenant).

### 2.4 Authentication & MFA
- **User invitation:** email invite with signed time-limited token, or direct admin creation with temporary password.
- **Password reset:** standard forgot-password flow with signed time-limited token.
- **MFA:** TOTP (RFC 6238) optional per user, enforceable per tenant by Owner.

---

## 2. Data Model

{{/MULTITENANT_YES_NO}}{{^MULTITENANT_YES_NO}}
## 2. Authentication & Users

### 2.1 Auth Method
{{AUTH_METHOD}}

### 2.2 User Roles
{{ROLES_LIST}}

### 2.3 Authentication Flow
- User creation via invitation or direct admin setup
- {{AUTH_METHOD}} login
- Short-lived access tokens (15 min), refresh tokens (30 days, rotating)
- MFA: TOTP optional, enforceable per user or org-wide

---

## 3. Data Model

{{/MULTITENANT_YES_NO}}
All tables include `id BIGINT UNSIGNED PK`, `created_at`, `updated_at`.

### Core Entities

<!-- Fill in the table with the main system entities. Example:
- `{{CORE_ENTITIES}}`

For each main entity, include:
- Table name
- Key columns
- Relationships
- Important constraints

Generic example:

- `users` -> id, email, password_hash, status, created_at, updated_at
- `{{CORE_ENTITIES|first}}_items` -> id, user_id (FK), status, data JSON, created_at, updated_at
- `{{CORE_ENTITIES|second}}_configs` -> id, user_id (FK), settings JSON, created_at

If multi-tenant, add `tenant_id` to all tenant-scoped tables.
-->

---

{{#MULTITENANT_YES_NO}}
## 3. Core Workflows
{{/MULTITENANT_YES_NO}}{{^MULTITENANT_YES_NO}}
## 4. Core Workflows
{{/MULTITENANT_YES_NO}}

<!-- Fill in the main system flows.

Use this exact step format so every workflow is anchored to an endpoint or an explicit UI-only marker:

**Flow: Flag running low**
1. User clicks "Flag as low" on the snack card. `UI only, no API call`
2. User submits the optional note. `POST /api/v{{VERSION}}/restock-requests`
3. On a 409 collision, the UI shows "Already flagged". `UI only, reads response body`

Rules:
- Every numbered step MUST end with exactly one backticked endpoint reference or a `UI only, ...` marker.
- Do not describe a mutation or read path here unless the matching endpoint appears in `api-endpoints.md`.
- Keep workflows scoped to v{{VERSION}} only. Defer future ideas with `Proposed { promote_when: "..." }`.
-->

---

{{#MULTITENANT_YES_NO}}
## 4. API Design
{{/MULTITENANT_YES_NO}}{{^MULTITENANT_YES_NO}}
## 5. API Design
{{/MULTITENANT_YES_NO}}

### URI Versioning
`/api/v{{VERSION}}/...`

### Authentication
{{AUTH_METHOD}}

### Response Envelope

**Success:**
```json
{
  "success": true,
  "data": { ... }
}
```

**Error:**
```json
{
  "success": false,
  "message": "Human-readable error",
  "errors": { ... }
}
```

### Pagination
Cursor-based (`?cursor=&limit=`) with `next_cursor` in response.

### Endpoint Groups (v{{VERSION}})
- `/auth` -> login, refresh, me
- `/users` -> CRUD
{{#INTEGRATIONS_IN_SCOPE}}
- {{. }} -> endpoints
{{/INTEGRATIONS_IN_SCOPE}}

---

{{#MULTITENANT_YES_NO}}
## 5. Infrastructure & Operations

### Database
- MySQL 8+, InnoDB, utf8mb4
- All FKs enforced. `tenant_id` indexed on every tenant-owned table.

### Queue
- Asynchronous operations queued (generation, publishing, etc.)
- Queue channels: `default`, {{STACK_SLUG|upper}}-specific channels

### Encryption
- AES-256 for sensitive fields (API keys, secrets, auth headers)
- Master key from environment, never in repo

### Observability
- {{OBSERVABILITY}}
- Health endpoint `/api/v{{VERSION}}/health`

---

## 6. Security & Audit
{{/MULTITENANT_YES_NO}}{{^MULTITENANT_YES_NO}}
## 5. Infrastructure & Operations

### Hosting
- {{HOSTING}}

### Observability
- {{OBSERVABILITY}}
- Health/status endpoint

### Database
- Primary DB: {{STACK_DESCRIPTION|extract:database}}
- Backups: automated daily, 30-day retention

---

## 6. Security & Audit
{{/MULTITENANT_YES_NO}}

- {{AUTH_METHOD}} + short-lived tokens
- MFA (TOTP) supported and optional{{#MULTITENANT_YES_NO}}, enforceable per tenant{{/MULTITENANT_YES_NO}}
- Strict {{#MULTITENANT_YES_NO}}tenant{{/MULTITENANT_YES_NO}}scoping on all queries
- Audit log for state transitions and config changes
- No rate limiting in v{{VERSION}}

---

## 7. Out of Scope for v{{VERSION}} (Deferred)

{{#NON_GOALS}}
- {{. }}
{{/NON_GOALS}}
- Advanced analytics / reporting
- Real-time collaboration features
- Third-party integrations (deferred)

---

{{#STEP2_RAN}}
{{#SHOW_FUTURE_VERSIONS}}
## Future Versions

{{#FUTURE_VERSION_ITEMS}}
- {{title}}. `Proposed { promote_when: "{{promote_when}}" }`
{{/FUTURE_VERSION_ITEMS}}

---
{{/SHOW_FUTURE_VERSIONS}}

{{#SHOW_LAUNCH_DEPENDENCIES}}
## Launch Dependencies

<!-- Use this section only when the skateboard does not stand alone.
Each bullet should describe one dependency that must ship together with v1.
-->
{{#LAUNCH_DEPENDENCIES}}
- {{.}}
{{/LAUNCH_DEPENDENCIES}}

---
{{/SHOW_LAUNCH_DEPENDENCIES}}
{{/STEP2_RAN}}

## 8. Open Questions & Assumptions

<!-- Use only the classified uncertainty labels:

- `TBD { blocks_coding: yes, reason: "..." }`
- `TBD { blocks_coding: no, reason: "...", default: "..." }`
- `Assumed { question: "...", default: "...", flip_cost: "low|medium|high" }`
- `Proposed { promote_when: "..." }`

Keep this section compact. Only include real unresolved items.
-->

---

## 9. Resolved Decisions (v{{VERSION}})

<!-- Fill in with architectural and product decisions made in this version:

1. Decision on API versioning strategy
2. Database per-tenant vs. shared with row-level security
3. Auth approach (OAuth, JWT, etc.)
4. Caching strategy
5. Background job approach
[... add more as needed] -->

---

{{#SHOW_SCOPE_DECISIONS}}
## Scope Decisions

<!-- Each item MUST carry a non-empty reason. Use one block per decision:
- Feature: ...
  Reason: ...
  Effect on v1: ...
-->
{{#SCOPE_DECISIONS}}
- Feature: {{feature}}
  Reason: {{reason}}
  Effect on v1: {{effect}}
{{/SCOPE_DECISIONS}}

---
{{/SHOW_SCOPE_DECISIONS}}

{{#SHOW_VALIDATION_PLAN}}
## Validation Plan

- Sample size: {{VALIDATION_PLAN_SAMPLE_SIZE}}
- Time window: {{VALIDATION_PLAN_TIME_WINDOW}}
- Success metric: {{VALIDATION_PLAN_SUCCESS_METRIC}}
- Kill threshold: {{VALIDATION_PLAN_KILL_THRESHOLD}}

---
{{/SHOW_VALIDATION_PLAN}}

## Implementation Readiness

### Safe to implement now
- Use concise bullets that cite the exact source line. Example: `Shared open queue is confirmed. (source: docs/{{PROJECT_SLUG}}-prd-v{{VERSION}}.md:42)`

### Needs explicit decision before coding
- Auto-populate from every `TBD { blocks_coding: yes, ... }` and every `Assumed { ... flip_cost: "medium|high" }`

### Needs decision before deployment (non-blocking for coding)
- Auto-populate from every `TBD { blocks_coding: no, ... }`

### Intentionally deferred from this version
- Auto-populate from every `Proposed { promote_when: "..." }` that explicitly defers to vNext
