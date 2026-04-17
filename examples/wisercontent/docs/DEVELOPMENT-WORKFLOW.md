# Development Workflow

**Project:** WiserContent Multi-Tenant Blog Platform API
**PHP:** 8.2+  |  **Framework:** Yii2 Advanced  |  **DB:** MySQL 8+

---

## 1. Environment Setup

### Docker

```bash
# Start services (from project root)
docker-compose up -d

# Enter the API container
docker exec -it <api-container> bash
```

### Composer

```bash
cd src/
composer install
```

### Environment Init

```bash
cd src/
php init --env=Development
```

This copies environment-specific configs from `src/environments/dev/` into the application directories.

---

## 2. Database Migrations: The Only Way to Change the Schema

**Rule:** Every database change goes through a migration. No manual SQL. No exceptions.

### Creating a Migration

```bash
cd src/
php yii migrate/create <descriptive_name>
# Example: php yii migrate/create create_tenants_table
# Creates: src/console/migrations/m260413_120000_create_tenants_table.php
```

### Migration Structure

```php
<?php

use yii\db\Migration;

class m260413_120000_create_tenants_table extends Migration
{
    public function safeUp(): bool
    {
        $this->createTable("{{%tenants}}", [
            "id" => $this->bigPrimaryKey()->unsigned(),
            "name" => $this->string(255)->notNull(),
            "slug" => $this->string(255)->notNull()->unique(),
            "timezone" => $this->string(64)->notNull()->defaultValue("UTC"),
            "status" => $this->string(32)->notNull()->defaultValue("active"),
            "mfa_required" => $this->boolean()->notNull()->defaultValue(false),
            "created_at" => $this->integer()->notNull(),
            "updated_at" => $this->integer()->notNull(),
        ]);

        return true;
    }

    public function safeDown(): bool
    {
        $this->dropTable("{{%tenants}}");
        return true;
    }
}
```

### Running Migrations

```bash
# Apply all pending migrations
php yii migrate

# Apply a specific number of migrations
php yii migrate 3

# Rollback the last migration
php yii migrate/down 1

# View migration history
php yii migrate/history

# View pending migrations
php yii migrate/new
```

### Migration Rules

| Rule | Details |
|---|---|
| Always use `safeUp()` / `safeDown()` | Wraps changes in a transaction for rollback safety |
| `safeDown()` must reverse `safeUp()` | Every migration must be reversible |
| Use `bigPrimaryKey()->unsigned()` | All PKs are `BIGINT UNSIGNED` |
| Use `bigInteger()->unsigned()` | All FKs and `tenant_id` columns |
| Use `{{%tablename}}` syntax | Supports table prefix configuration |
| Add foreign keys | `fk-{table}-{column}` naming convention |
| Add indexes | `idx-{table}-{columns}` naming convention |
| One logical change per migration | Don't combine unrelated schema changes |
| Never modify a deployed migration | Create a new migration for fixes |
| No raw data in migrations | Use seeders/fixtures for test data |

### Common Migration Operations

```php
// Add a column
$this->addColumn("{{%users}}", "mfa_secret", $this->string()->after("password_hash"));

// Drop a column
$this->dropColumn("{{%users}}", "mfa_secret");

// Add an index
$this->createIndex("idx-content_items-tenant_id-status", "{{%content_items}}", ["tenant_id", "status"]);

// Add a foreign key
$this->addForeignKey(
    "fk-content_items-tenant_id",
    "{{%content_items}}",
    "tenant_id",
    "{{%tenants}}",
    "id",
    "CASCADE",
    "CASCADE"
);

// Rename a column
$this->renameColumn("{{%users}}", "old_name", "new_name");

// Change column type
$this->alterColumn("{{%tenants}}", "name", $this->string(512)->notNull());
```

---

## 3. Static Analysis: PHPStan Level 8

### Configuration

PHPStan config: `src/phpstan.neon`

**Target level: 8** (maximum strictness). All new code must pass Level 8. When modifying existing code, bring touched files up to Level 8.

### Running PHPStan

```bash
cd src/

# Full analysis
composer phpstan

# Or directly
./vendor/bin/phpstan analyse -c ./phpstan.neon --memory-limit=-1 --level=8 --no-progress .

# Analyse a specific file or directory
./vendor/bin/phpstan analyse -c ./phpstan.neon --level=8 common/models/Category.php

# Generate a baseline (for legacy code only — do not add new entries)
./vendor/bin/phpstan analyse -c ./phpstan.neon --level=8 --generate-baseline
```

### What Level 8 Requires

| Check | Example |
|---|---|
| Return type declarations | `public function getName(): string` |
| Parameter type declarations | `public function setName(string $name): void` |
| Property type declarations | `private int $count = 0;` |
| Strict null checks | `$model->name` fails if `$model` could be `null` |
| Union types for nullable | `?string` or `string\|null` |
| No mixed types | Every variable must have a known type |
| Array shapes | `@param array{name: string, id: int} $data` |
| Generic types | `ActiveQuery` return types on relation methods |
| Dead code detection | Unreachable code and unused variables |

### PHPStan + Yii2 Tips

```php
// Problem: PHPStan doesn't know about magic properties
// Solution: Use @property annotations on every model
/**
 * @property int $id
 * @property string $name
 */
class Tenant extends ActiveRecord { }

// Problem: find()->one() returns ActiveRecord|array|null
// Solution: Type-narrow with null check
$tenant = Tenant::findOne($id);
if ($tenant === null) {
    throw new NotFoundHttpException("Tenant not found.");
}
// PHPStan now knows $tenant is Tenant, not null

// Problem: Yii::$app->user->identity type is IdentityInterface|null
// Solution: Assert the concrete type
/** @var User $identity */
$identity = Yii::$app->user->getIdentity();
assert($identity instanceof User);
```

### Suppressing Errors

Only suppress PHPStan errors when the code is correct but PHPStan cannot verify it:

```php
// Acceptable: Yii2 magic that PHPStan can't follow
/** @phpstan-ignore-next-line Yii2 DI container returns typed component */
$queue = Yii::$app->queue;

// NOT acceptable: suppressing to avoid fixing actual type issues
/** @phpstan-ignore-next-line */
$name = $thing->name; // $thing could be null — FIX THIS
```

---

## 4. Code Style: PHPCS / PHPCBF

### Configuration

Code style config: `src/.phpcs.xml`
Standard: PSR-2 + PHPCompatibility (PHP 8.2+)

### Running

```bash
cd src/

# Check code style (report only)
composer phpcs

# Auto-fix code style issues
composer phpcbf

# Check a specific file
./vendor/bin/phpcs --standard=./.phpcs.xml common/models/Tenant.php

# Auto-fix a specific file
./vendor/bin/phpcbf --standard=./.phpcs.xml common/models/Tenant.php
```

### Key Rules

| Rule | Enforcement |
|---|---|
| Double quotes for strings | `"hello"` not `'hello'` |
| Short array syntax | `[]` not `array()` |
| PSR-2 formatting | Braces, spacing, indentation |
| PHP 8.2 compatibility | No deprecated features |
| Concatenation spacing | `"foo" . "bar"` (spaces around `.`) |
| No long lines | Soft limit (excluded from PSR2) |

### Excluded from PHPCS

- Migrations (`m\d{6}_\d{6}_*.php`)
- Vendor directory
- Test files
- View templates
- Web assets

---

## 5. Testing: Codeception

### Configuration

- Global: `src/codeception.yml`
- API suite: `src/api/tests/api.suite.yml`

### Running Tests

```bash
cd src/

# Run all tests
composer tests

# Run API tests only
./vendor/bin/codecept run api

# Run a specific test class
./vendor/bin/codecept run api AuthenticateCest

# Run a specific test method
./vendor/bin/codecept run api AuthenticateCest:successfulAuthentication

# Run with verbose output
./vendor/bin/codecept run api --debug
```

### Writing Tests

API tests use the Cest format:

```php
namespace api\tests\api;

use api\tests\ApiTester;

class CategoryCest
{
    public function createCategory(ApiTester $I): void
    {
        $I->amBearerAuthenticated($this->getValidToken());
        $I->sendPOST("/v1/categories", [
            "name" => "Technology",
            "slug" => "technology",
        ]);
        $I->seeResponseCodeIs(200);
        $I->seeResponseIsJson();
        $I->seeResponseContainsJson([
            "success" => true,
            "data" => ["name" => "Technology"],
        ]);
    }

    public function createCategoryRequiresAuth(ApiTester $I): void
    {
        $I->sendPOST("/v1/categories", ["name" => "Test"]);
        $I->seeResponseCodeIs(401);
    }

    public function cannotAccessOtherTenantCategory(ApiTester $I): void
    {
        // See YII2-TENANT-FILTERING.md for isolation test patterns
    }
}
```

### Test Requirements

- Every new endpoint MUST have API tests.
- Every tenant-scoped model MUST have cross-tenant isolation tests.
- Use `FakerPHP` for generating test data.
- Tests run against a real database, not mocks.
- Test both success and error paths.

---

## 6. Pre-Commit Checklist

Before committing any code, run all checks:

```bash
cd src/

# 1. Run PHPStan (Level 8)
composer phpstan

# 2. Run PHPCS
composer phpcs

# 3. Auto-fix style issues
composer phpcbf

# 4. Run tests
composer tests

# Or run PHPStan + PHPCS together
composer check
```

All four checks must pass before a commit is accepted.

---

## 7. Branch & Commit Conventions

### Branch Naming

```
feature/<descriptive-name>     # New features
fix/<descriptive-name>         # Bug fixes
refactor/<descriptive-name>    # Code refactoring
migration/<descriptive-name>   # Database schema changes
```

### Commit Messages

```
feat: add tenant CRUD endpoints
fix: enforce tenant_id on category queries
refactor: extract TenantScopeTrait from models
migration: create content_items and content_drafts tables
test: add cross-tenant isolation tests for categories
chore: update PHPStan to level 8
```

---

## 8. Adding a New Feature: Step by Step

### Example: Adding a new tenant-scoped resource (Categories)

**Step 1: Create the migration**
```bash
php yii migrate/create create_categories_table
```
Write the migration with `tenant_id`, foreign keys, and indexes.

**Step 2: Run the migration**
```bash
php yii migrate
```

**Step 3: Create the model**
Create `src/common/models/Category.php` with:
- `TenantScopeTrait`
- Full `@property` annotations
- `rules()` with all validations
- `behaviors()` with `TimestampBehavior`
- Relations to tenant and other models
- Business logic methods

**Step 4: Create the controller**
Create `src/api/controllers/v1/CategoryController.php` extending `api\components\Controller`.

**Step 5: Add URL rules**
Update `src/api/config/url.php` with the new routes.

**Step 6: Write tests**
Create `src/api/tests/api/CategoryCest.php` with:
- CRUD operation tests
- Authentication requirement tests
- Validation error tests
- Cross-tenant isolation tests

**Step 7: Run all checks**
```bash
composer check   # PHPStan + PHPCS
composer tests   # Codeception
```

**Step 8: Commit**
```bash
git add src/console/migrations/m260413_*
git add src/common/models/Category.php
git add src/api/controllers/v1/CategoryController.php
git add src/api/config/url.php
git add src/api/tests/api/CategoryCest.php
git commit -m "feat: add categories CRUD with tenant isolation"
```

---

## 9. Queue Jobs Development

### Creating a Job

```php
namespace common\jobs;

use yii\queue\RetryableJobInterface;
use yii\queue\Queue;

class GenerateContentJob implements RetryableJobInterface
{
    public int $contentItemId;
    public int $tenantId;

    public function execute($queue): void
    {
        // Set tenant context for the job
        \Yii::$app->params["tenantId"] = $this->tenantId;

        // ... job logic

        unset(\Yii::$app->params["tenantId"]);
    }

    public function getTtr(): int
    {
        return 300; // 5 minutes
    }

    public function canRetry(int $attempt, $error): bool
    {
        return $attempt < 3;
    }
}
```

### Queue Channels

| Channel | Purpose |
|---|---|
| `generation` | AI content generation (writer) |
| `revision` | AI content revision |
| `publish` | Webhook publishing |
| `research` | Keyword research, AlsoAsked API |
| `default` | Everything else |

### Dispatching a Job

```php
Yii::$app->queue->push(new GenerateContentJob([
    "contentItemId" => $contentItem->id,
    "tenantId" => $contentItem->tenant_id,
]));
```

---

## 10. Encryption for Sensitive Fields

Fields requiring encryption (per PRD): AI API keys, Langfuse secret keys, webhook auth headers.

```php
// Encrypt before saving
$model->api_key_encrypted = Yii::$app->security->encryptByKey(
    $plaintextKey,
    Yii::$app->params["encryptionKey"]
);

// Decrypt at point of use
$plaintextKey = Yii::$app->security->decryptByKey(
    $model->api_key_encrypted,
    Yii::$app->params["encryptionKey"]
);
```

- The master encryption key comes from environment variables, never from code or config files in the repo.
- Never log, dump, or return decrypted values in API responses.

---

## 11. Troubleshooting

### Migration fails to apply
```bash
# Check migration status
php yii migrate/history
php yii migrate/new

# If stuck, check for partial application
# Never manually modify migration_history table — fix the migration code
```

### PHPStan errors on Yii2 magic
- Add `@property` annotations to models
- Use `@var` inline annotations for Yii2 DI components
- Check `phpstan.neon` bootstrapFiles includes `Yii.php`

### PHPCS false positives on migrations
- Migrations are excluded from PHPCS checks by pattern
- If a new migration triggers PHPCS, verify the filename matches `m\d{6}_\d{6}_*.php`

### Tests fail with database errors
- Ensure test database exists and migrations are applied
- Check `src/api/tests/api.suite.yml` for correct database config
- Run `php yii migrate --interactive=0` in test environment
