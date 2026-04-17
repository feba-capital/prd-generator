# AGENTS.md: AI Agent Instructions

**Project:** WiserContent Multi-Tenant Content Platform API
**Stack:** PHP 8.2+, Yii2 Advanced Template, MySQL 8+, Dragonfly (Queue)
**Architecture:** API-first, single-database multi-tenant with row-level `tenant_id` scoping

---

## 1. Mandatory Reading Before Any Work

Before writing or modifying code, you MUST read and follow these project guides:

- **[YII2-BEST-PRACTICES.md](YII2-BEST-PRACTICES.md)**: coding standards, SOLID/DRY/KISS principles, Yii2 patterns
- **[YII2-TENANT-FILTERING.md](YII2-TENANT-FILTERING.md)**: tenant isolation rules, TenantScopeTrait, query safety
- **[DEVELOPMENT-WORKFLOW.md](DEVELOPMENT-WORKFLOW.md)**: migrations, PHPStan Level 8, PHPCBF, testing, PR process
- **[wisercontent-prd-v2.md](wisercontent-prd-v2.md)**: full product requirements document

---

## 2. Project Structure

```
src/
  api/                    # HTTP API application
    components/           # Base Controller, ErrorHandler
    config/               # API config, URL rules
    controllers/v1/       # Versioned REST controllers
    tests/                # Codeception API tests
    web/                  # Entry point (index.php)
  common/                 # Shared across api & console
    components/           # Shared components, traits, behaviors
    config/               # DB connection, shared config
    helpers/              # Utility classes
    jobs/                 # Queue job classes
    mail/                 # Email templates
    models/               # ActiveRecord models (THE source of truth)
  console/                # CLI application
    config/               # Console config
    controllers/          # Console commands
    migrations/           # ALL database migrations live here
  environments/           # Environment-specific config overrides
    dev/ | stage/ | prod/
```

---

## 3. Core Rules: Non-Negotiable

### 3.1 Every Database Change Requires a Migration

- **Never** modify the database directly. Every schema change goes through `src/console/migrations/`.
- Use `safeUp()` / `safeDown()` for transactional safety.
- Migration naming: `m{YYMMDD}_{HHMMSS}_{descriptive_name}.php`
- Use `{{%tablename}}` syntax for table prefix support.
- All IDs are `BIGINT UNSIGNED`. No UUIDs, no string IDs.
- Every tenant-owned table MUST have `tenant_id BIGINT UNSIGNED NOT NULL` with a foreign key and index.

### 3.2 Tenant Isolation is Absolute

- Every query on a tenant-owned table MUST filter by `tenant_id`. No exceptions.
- Use the `TenantScopeTrait` on all tenant-scoped models (see YII2-TENANT-FILTERING.md).
- Cross-tenant data access is only allowed for `PlatformAdmin` operations, and must be explicit and audited.
- **Never** trust client-provided `tenant_id`; always derive it from the authenticated JWT token.
- Test for cross-tenant leakage in every model test.

### 3.3 PHPStan Level 8 Compliance

- All new and modified code MUST pass PHPStan Level 8.
- Run: `composer phpstan` (configured in `src/phpstan.neon`)
- No `@phpstan-ignore` without a comment explaining why.
- Proper type declarations on all method signatures, properties, and return types.

### 3.4 PHPCBF / PHPCS Compliance

- All code MUST pass PHPCS with the project's `.phpcs.xml` ruleset (PSR-2 + PHPCompatibility 8.2+).
- Run: `composer phpcs` to check, `composer phpcbf` to auto-fix.
- Double quotes required for strings.
- Modern short array syntax `[]` only (no `array()`).

### 3.5 No Direct SQL Queries

- Use ActiveRecord and Query Builder exclusively.
- Raw SQL is only permitted in migrations.
- Never use `Yii::$app->db->createCommand()` with string interpolation.

---

## 4. Code Principles

### DRY (Don't Repeat Yourself)
- Extract shared logic into traits, behaviors, or base classes in `common/components/`.
- Reuse existing model methods. Check before writing new ones.

### SOLID
- **S**: One model per table. One controller per resource. One job per task.
- **O**: Use Yii2 behaviors and events for extensibility, not conditionals.
- **L**: Subtypes must honor parent contracts, especially `TenantScopeTrait` guarantees.
- **I**: Keep interfaces focused. Controller actions should delegate to models/services.
- **D**: Inject dependencies via Yii2 DI container or constructor, not `Yii::$app->` singletons in models.

### KISS (Keep It Simple)
- No premature abstractions. If a pattern is used once, inline it.
- Prefer Yii2's built-in mechanisms (behaviors, validators, events) over custom frameworks.
- No feature flags. No backwards-compatibility shims. Change the code directly.

### Maintainability
- Code should be readable without comments. Use descriptive names.
- Only add comments where business logic isn't self-evident (e.g., "why" not "what").
- Keep methods short: if a method exceeds 30 lines, consider extracting.

---

## 5. Model Conventions

```php
namespace common\models;

use yii\db\ActiveRecord;
use yii\behaviors\TimestampBehavior;
use common\components\TenantScopeTrait;

/**
 * @property int $id
 * @property int $tenant_id
 * @property string $name
 * @property int $created_at
 * @property int $updated_at
 */
class Category extends ActiveRecord
{
    use TenantScopeTrait;

    public static function tableName(): string
    {
        return "{{%categories}}";
    }

    public function rules(): array
    {
        return [
            [["tenant_id", "name", "slug"], "required"],
            [["tenant_id"], "integer"],
            [["name", "slug"], "string", "max" => 255],
            [["slug"], "unique", "targetAttribute" => ["tenant_id", "slug"]],
        ];
    }

    public function behaviors(): array
    {
        return [
            TimestampBehavior::class,
        ];
    }
}
```

### Required model elements:
- PHPDoc `@property` annotations for all columns
- `tableName()` with `{{%prefix}}` syntax
- `rules()` with complete validation
- `behaviors()` with `TimestampBehavior` at minimum
- `TenantScopeTrait` on every tenant-owned model
- Typed return declarations on all methods

---

## 6. Controller Conventions

- All API controllers extend `api\components\Controller`
- Namespace: `api\controllers\v1\`
- Use `buildSuccessResponse()` and `buildErrorResponse()` from the base controller
- Validate input through model rules, not manual checks in controllers
- Keep controllers thin; business logic belongs in models or service classes
- Authentication is handled by the base controller's `behaviors()`; do not override unless adding `optional` actions

---

## 7. Migration Conventions

```php
use yii\db\Migration;

class m260413_120000_create_categories_table extends Migration
{
    public function safeUp(): bool
    {
        $this->createTable("{{%categories}}", [
            "id" => $this->bigPrimaryKey()->unsigned(),
            "tenant_id" => $this->bigInteger()->unsigned()->notNull(),
            "name" => $this->string(255)->notNull(),
            "slug" => $this->string(255)->notNull(),
            "description" => $this->text(),
            "created_at" => $this->integer()->notNull(),
            "updated_at" => $this->integer()->notNull(),
        ]);

        $this->addForeignKey(
            "fk-categories-tenant_id",
            "{{%categories}}",
            "tenant_id",
            "{{%tenants}}",
            "id",
            "CASCADE",
            "CASCADE"
        );

        $this->createIndex(
            "idx-categories-tenant_id",
            "{{%categories}}",
            "tenant_id"
        );

        $this->createIndex(
            "idx-categories-tenant_id-slug",
            "{{%categories}}",
            ["tenant_id", "slug"],
            true
        );

        return true;
    }

    public function safeDown(): bool
    {
        $this->dropTable("{{%categories}}");
        return true;
    }
}
```

### Migration rules:
- Always use `safeUp()` / `safeDown()` (never `up()` / `down()`)
- `safeDown()` must fully reverse `safeUp()`
- Use `bigPrimaryKey()->unsigned()` for all PKs
- Use `bigInteger()->unsigned()` for all FKs and `tenant_id`
- Add foreign keys with descriptive names: `fk-{table}-{column}`
- Add indexes with descriptive names: `idx-{table}-{columns}`
- Composite indexes on `tenant_id` + frequently queried columns

---

## 8. Queue Jobs

- Job classes live in `src/common/jobs/`.
- Implement `yii\queue\RetryableJobInterface` for jobs that can be retried.
- Queue channels: `generation`, `revision`, `publish`, `research`, `default`.
- Jobs must be idempotent: safe to retry without side effects.
- Always log `langfuse_trace_id` on AI-related jobs.

---

## 9. Testing

- Framework: Codeception 5
- Test location: `src/api/tests/`
- Run: `composer tests`
- Every new endpoint MUST have corresponding API tests.
- Every tenant-scoped model MUST have a test asserting cross-tenant isolation.
- Use Faker for test data generation.

---

## 10. Security Checklist

- [ ] Encrypted fields (AI keys, Langfuse secrets, webhook auth headers) use AES-256 encryption
- [ ] No plaintext secrets in code, config, or migrations
- [ ] All user input validated through model `rules()`, never trusted raw
- [ ] `tenant_id` always derived from JWT, never from request body
- [ ] No SQL injection vectors (use parameterized queries via ActiveRecord)
- [ ] Audit log entries created for all state transitions and config changes
- [ ] JWT tokens are short-lived (15 min access, 30 day refresh with rotation)

---

## 11. What NOT to Do

- **Never** skip migrations and modify the DB directly
- **Never** query tenant-owned data without `tenant_id` filtering
- **Never** store secrets in plain text
- **Never** use `array()` syntax (use `[]`)
- **Never** suppress PHPStan errors without justification
- **Never** add `@phpstan-ignore-next-line` to bypass real type issues
- **Never** put business logic in controllers: delegate to models/services
- **Never** use `die()`, `exit()`, `var_dump()`, or `print_r()` in committed code
- **Never** hardcode environment-specific values: use config/environment variables
