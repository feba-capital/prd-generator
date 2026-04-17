# Development Workflow

**Project:** {{PROJECT_NAME}}
**Stack:** {{STACK_DESCRIPTION}}

---

## 1. Environment Setup

### Local Development

Refer to {{STACK_BEST_PRACTICES_FILE}} for stack-specific setup (Node, Python, PHP, etc.).

Common steps:
1. Clone repository
2. Install dependencies: `npm install`, `composer install`, `pip install`, etc.
3. Copy environment file: `.env.example` → `.env`
4. Initialize database: migrations, seeders
5. Start dev server

### Docker (if applicable)

```bash
docker-compose up -d
docker exec -it <app-container> bash
```

---

## 2. Database Migrations

**Rule:** Every database change goes through a migration. No manual SQL.

### Creating a Migration

```bash
# Framework-specific command
npm run migrate:create <name>
# or
php yii migrate/create <name>
# or
python manage.py makemigrations <name>
```

Naming: `m{YYMMDD}_{HHMMSS}_{descriptive_name}`

### Running Migrations

```bash
# Apply all pending
<migration-command>

# Rollback last
<rollback-command> 1

# View history
<history-command>
```

### Migration Rules

| Rule | Details |
|---|---|
| Use transactions | Wrap in `safeUp()` / `safeDown()` (or framework equivalent) |
| Reversible | `safeDown()` must fully reverse `safeUp()` |
| IDs | All PKs: `BIGINT UNSIGNED` (or equivalent in your stack) |
| FKs | Descriptive names: `fk-{table}-{column}` |
| Indexes | Descriptive names: `idx-{table}-{columns}` |
| One change per migration | Don't combine unrelated schema changes |
| Never modify deployed | Create new migration for fixes |

---

## 3. Static Analysis

### Type Checking

Stack: {{STACK_SLUG}}
Target level: **Maximum strictness** (e.g., PHPStan Level 8, TypeScript strict mode, mypy strict)

```bash
make check-types
# or
npm run type-check
# or
composer phpstan
```

### Code Style

Framework standard: {{STACK_BEST_PRACTICES_FILE}}

```bash
make check-style
# or
npm run lint
# or
composer phpcs
```

**Auto-fix:**

```bash
make fix-style
# or
npm run lint:fix
# or
composer phpcbf
```

---

## 4. Testing

Framework: Stack-native (Jest, Codeception, pytest, etc.)

```bash
make test
# or
npm test
# or
composer tests
```

### Test Requirements

- Every new endpoint MUST have tests
- Every {{#MULTITENANT_YES_NO}}tenant-scoped{{/MULTITENANT_YES_NO}}data model MUST have isolation tests
- Test both success and error paths
- Use framework's test factories/fixtures for data generation

### Writing Tests

Refer to {{STACK_BEST_PRACTICES_FILE}} for test patterns and examples.

---

## 5. Pre-Commit Checklist

Before committing, run:

```bash
make check        # Type + style checks
make test         # All tests must pass
```

Commit only after both pass.

---

## 6. Branch & Commit Conventions

### Branch Naming

```
feature/<descriptive-name>     # New features
fix/<descriptive-name>         # Bug fixes
refactor/<descriptive-name>    # Code refactoring
migration/<descriptive-name>   # Database migrations
```

### Commit Messages

```
feat: add user CRUD endpoints
fix: enforce tenant_id on queries
refactor: extract validation logic
test: add cross-tenant isolation tests
chore: update dependencies
```

---

## 7. Adding a New Feature — Step by Step

### Example: Adding a tenant-scoped resource

**Step 1: Create the migration**
```bash
<migration-command> create_<resource>_table
```

**Step 2: Write the migration code**
- Create table with appropriate columns
- Add FKs and indexes
- Ensure reversible

**Step 3: Run the migration**
```bash
<apply-migration-command>
```

**Step 4: Create the model**
- Add {{#MULTITENANT_YES_NO}}`tenant_id` scope trait{{/MULTITENANT_YES_NO}}user scope validation
- Full type/property declarations
- Validation rules
- Relations to other models

**Step 5: Create the controller/handler**
- CRUD actions
- Authorization checks
- Input validation
- Response formatting

**Step 6: Write tests**
- CRUD operation tests
- Auth requirement tests
- Validation error tests
{{#MULTITENANT_YES_NO}}
- Cross-tenant isolation tests
{{/MULTITENANT_YES_NO}}

**Step 7: Run all checks**
```bash
make check
make test
```

**Step 8: Commit**
```bash
git commit -m "feat: add <resource> with CRUD and tenant isolation"
```

---

## 8. Queue Jobs (if applicable)

### Creating a Job

- Implement framework's job interface (RetryableJobInterface, Task, celery task, etc.)
- Store in dedicated `jobs/` directory
- Idempotent: safe to retry without side effects
- Log important context (IDs, trace IDs, etc.)

### Dispatching

```bash
Queue.push(new JobClass([...]))
# or framework equivalent
```

### Queue Channels

- `default` — general background work
- `{{STACK_SLUG}}-specific` — domain-specific channels

---

## 9. Encryption for Sensitive Fields

Fields requiring encryption: API keys, secrets, auth headers.

Framework pattern: Use ORM's built-in encryption or a dedicated encryption service.

```pseudo
// Encrypt before saving
model.encrypted_field = encrypt(plaintextValue)

// Decrypt at point of use
plaintextValue = decrypt(model.encrypted_field)
```

Master encryption key: **Environment variable**, never in code.

---

## 10. Troubleshooting

### Migration fails
- Check migration history: `<history-command>`
- Verify migrations are reversible
- Never manually modify migration tables

### Type/Lint errors
- Consult {{STACK_BEST_PRACTICES_FILE}} for patterns
- Use proper type declarations
- Add justification comments if suppressing errors

### Tests fail
- Ensure test DB is initialized and migrations applied
- Check test config in {{STACK_SLUG}} config
- Run migrations in test environment before tests

---

*End DEVELOPMENT-WORKFLOW.md — follow these steps on every change.*
