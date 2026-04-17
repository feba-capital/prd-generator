# Service Boundaries

Defines the domain modules, ownership boundaries, and coupling rules for `{{PROJECT_NAME}}`. This doc describes **architecture** (who owns what), not **implementation** (controllers, methods). Controllers live in code, not in docs.

---

## Domain Modules

List the top-level domain areas. Each module owns a set of entities, a set of user flows, and emits a set of events.

### Module: `{{CORE_ENTITIES|first|titleize}}`

**Owned entities:** `{{CORE_ENTITIES|first}}` + subordinate entities (list them)
**Owned flows:** (list the user flows from PRD that live here)
**External dependencies:** (integrations, if any)
**Emits events:** `{{CORE_ENTITIES|first|downcase}}.created`, `{{CORE_ENTITIES|first|downcase}}.updated`, etc.

---

### Module: `{{CORE_ENTITIES|second|titleize}}`

**Owned entities:** `{{CORE_ENTITIES|second}}`
**Owned flows:** (list)
**External dependencies:** (list)
**Emits events:** (list)

---

### Module: `Users & Auth`

**Owned entities:** `users`, `sessions`, `refresh_tokens`{{#MULTITENANT_YES_NO}}, `user_tenants`{{/MULTITENANT_YES_NO}}
**Owned flows:** signup, login, password reset, MFA{{#MULTITENANT_YES_NO}}, tenant switching{{/MULTITENANT_YES_NO}}
**Emits events:** `user.created`, `user.login`, `user.logout`

---

## Ownership Boundaries

A boundary rule is "Module A must not directly read/write Module B's tables". Cross-module interaction happens via module's public interface (service methods or events).

| Module | Can read directly | Must go through interface |
|---|---|---|
| `{{CORE_ENTITIES|first|titleize}}` | its own tables | all others |
| `{{CORE_ENTITIES|second|titleize}}` | its own tables | all others |
| `Users & Auth` | its own tables | all others |

---

## Coupling to Avoid

1. **Do not join across module tables in controllers.** If `{{CORE_ENTITIES|first|titleize}}` needs data from `{{CORE_ENTITIES|second|titleize}}`, call the module's service method, do not SQL-join directly.
2. **Do not call another module's internal functions.** Only public service methods and event subscriptions.
3. **Do not pass raw DB models across module boundaries.** Use DTOs / typed interfaces.
4. **Do not let UI components read from multiple module stores in one render.** Aggregate in a service layer.

---

## Shared Infrastructure (not a module)

These are cross-cutting and can be imported by any module:

- Logging
- Error handling / error envelope
- Auth middleware
{{#MULTITENANT_YES_NO}}- Tenant scoping middleware
{{/MULTITENANT_YES_NO}}- Validation framework
- Encryption utilities

---

## Event Bus (if used)

<!-- Optional section. Fill only if the project has async events.
Example:
| Event | Publisher | Subscribers |
|---|---|---|
| `order.created` | Orders module | Notifications, Analytics |
-->

---

## Decisions (v{{VERSION}})

1. Module split confirmed as: (list modules)
2. Communication style: `Assumed { question: "Is inter-module communication synchronous, event-driven, or hybrid?", default: "synchronous service calls", flip_cost: "medium" }`
3. Transactions across modules: `TBD { blocks_coding: yes, reason: "confirm whether any v1 flow must mutate more than one module atomically" }`

---

*This file replaces the legacy `api-controllers.md`. Controllers are implementation details → they live in code. Boundaries are architectural → they live here.*
