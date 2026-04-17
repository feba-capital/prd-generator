# AGENTS.md — AI Agent Instructions

**Project:** {{PROJECT_NAME}}
**Stack:** {{STACK_DESCRIPTION}}
**Architecture:** API-first{{#MULTITENANT_YES_NO}}, multi-tenant{{/MULTITENANT_YES_NO}}

---

## 1. Mandatory Reading Before Any Work

Before writing or modifying code, you MUST read and follow these project guides:

- **[{{STACK_BEST_PRACTICES_FILE}}]({{STACK_BEST_PRACTICES_FILE}})** — Coding standards, SOLID/DRY/KISS principles, {{STACK_SLUG}} patterns
{{#MULTITENANT_YES_NO}}
- **[{{STACK_SLUG|upper}}-TENANT-FILTERING.md]({{STACK_SLUG|upper}}-TENANT-FILTERING.md)** — Tenant isolation rules, query safety
{{/MULTITENANT_YES_NO}}
- **[DEVELOPMENT-WORKFLOW.md](DEVELOPMENT-WORKFLOW.md)** — Build process, static analysis, testing, PR process
- **[{{PROJECT_SLUG}}-prd-v{{VERSION}}.md]({{PROJECT_SLUG}}-prd-v{{VERSION}}.md)** — Full product requirements

---

## 2. Project Structure

```
src/
  api/                    # HTTP API application
    components/           # Base Controller, ErrorHandler
    config/               # API config, URL rules
    controllers/v1/       # Versioned REST controllers
    tests/                # API tests
    web/                  # Entry point
  common/                 # Shared across api & console
    components/           # Shared utilities, traits, behaviors
    config/               # DB connection, config
    helpers/              # Utility classes
    jobs/                 # Async job classes
    mail/                 # Email templates
    models/               # Data models (source of truth)
  console/                # CLI application
    config/               # Console config
    controllers/          # Console commands
    migrations/           # Database migrations
  environments/           # Environment-specific config
    dev/ | stage/ | prod/
```

---

## 3. Core Rules — Non-Negotiable

### 3.1 Code Quality Standards

Refer to `{{STACK_BEST_PRACTICES_FILE}}` for all language/framework-specific practices. Key standards:
- Type safety (strictest level supported by the stack)
- No raw DB queries — use ORM/Query Builder exclusively
- Code style checks must pass before commit
- Unit tests required for new features and models

### 3.2 {{#MULTITENANT_YES_NO}}Tenant {{/MULTITENANT_YES_NO}}Data Isolation

{{#MULTITENANT_YES_NO}}
- Every query on a tenant-owned table MUST filter by `tenant_id`. No exceptions.
- Refer to `{{STACK_SLUG|upper}}-TENANT-FILTERING.md` for isolation patterns and tests.
- Cross-tenant data access only for `PlatformAdmin` operations, always audited.
- Never trust client-provided `tenant_id` → derive from JWT.
{{/MULTITENANT_YES_NO}}
{{^MULTITENANT_YES_NO}}
- User data is never exposed across user boundaries.
- Row-level security enforced via authenticated context.
- All queries include user/org scope filter.
{{/MULTITENANT_YES_NO}}

### 3.3 Static Analysis & Linting

All code must pass:
- Type checker (strictest level)
- Style linter (stack's standard ruleset)
- Before commit, run full check: `make check` or equivalent

### 3.4 No Direct SQL Queries

- Use ORM/ActiveRecord and Query Builder exclusively
- Raw SQL only permitted in migrations

---

## 4. Code Principles

### DRY (Don't Repeat Yourself)
- Extract shared logic into utilities, base classes, or traits
- Reuse existing model methods before writing new ones

### SOLID
- **S**: One model per entity. One controller per resource.
- **O**: Use composition and traits for extensibility, not deep conditionals
- **L**: Subtypes honor parent contracts
- **I**: Focused interfaces, thin controllers
- **D**: Dependency injection, not singletons in business logic

### KISS (Keep It Simple)
- No premature abstractions
- Prefer built-in framework features over custom frameworks
- Change code directly, no feature flags

### Maintainability
- Code readable without comments; comments explain "why", not "what"
- Methods under 30 lines
- Descriptive names

---

## 5. Testing

- **Framework:** Framework-native test suite
- **Coverage:** Every new endpoint + cross-{{#MULTITENANT_YES_NO}}tenant{{/MULTITENANT_YES_NO}} isolation test
- **Before commit:** `make test` or equivalent must pass

---

## 6. Security Checklist

- [ ] Sensitive fields encrypted (API keys, secrets, auth headers)
- [ ] No plaintext secrets in code/config/migrations
- [ ] All user input validated
- [ ] {{#MULTITENANT_YES_NO}}`tenant_id` always from JWT, never request body{{/MULTITENANT_YES_NO}}User scope always verified
- [ ] No SQL injection vectors (use parameterized queries)
- [ ] Audit log for state transitions and config changes
- [ ] JWT tokens short-lived (access: 15 min, refresh: 30 days with rotation)

---

## 7. What NOT to Do

- **Never** skip migrations, modify DB directly
{{#MULTITENANT_YES_NO}}
- **Never** query {{STACK_SLUG|uppercase}}-scoped data without `tenant_id` filter
{{/MULTITENANT_YES_NO}}
- **Never** store secrets in plaintext
- **Never** put business logic in controllers → delegate to models
- **Never** use `die()`, `exit()`, `var_dump()` in committed code
- **Never** hardcode environment-specific values → use config/env vars
- **Never** suppress type/lint errors without justification

---

## 8. Git & Commit Workflow

### Branch Naming
```
feature/<descriptive-name>     # New features
fix/<descriptive-name>         # Bug fixes
refactor/<descriptive-name>    # Code refactoring
```

### Commit Messages
```
feat: add user CRUD endpoints
fix: enforce tenant_id on queries
refactor: extract common validation
test: add cross-tenant isolation tests
```

### Pre-Commit
1. Run type checker: `make check` or equivalent
2. Run tests: `make test` or equivalent
3. All checks must pass before committing

---

*End AGENTS.md — follow these guidelines on every task.*
