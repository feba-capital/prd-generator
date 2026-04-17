# Yii2 Tenant Filtering Guide

**Architecture:** Single MySQL database, row-level isolation via `tenant_id`
**Rule:** Every query on a tenant-owned table MUST include a `tenant_id` filter. No exceptions.

---

## 1. Tenancy Model Overview

This platform uses **single-database multi-tenancy** with `tenant_id BIGINT UNSIGNED` on every tenant-owned table. Tenant isolation is enforced at the ActiveRecord layer, not the database layer. This means a bug in application code can leak data across tenants → so the safeguards described here are mandatory.

### Tenant-Owned Tables (require `tenant_id`)
All tables except: `users`, `ai_providers`, `global_config`

### Global Tables (no `tenant_id`)
- `users` → platform-wide accounts (tenant membership is via `user_tenants`)
- `ai_providers` → global enum table
- `global_config` → single global configuration

### The `tenants` Table
The `tenants` table itself does NOT have a `tenant_id` column. It IS the tenant.

---

## 2. TenantScopeTrait

Every tenant-scoped model MUST use `TenantScopeTrait`. This trait automatically injects `tenant_id` conditions into all queries.

### Implementation

```php
namespace common\components;

use Yii;
use yii\db\ActiveQuery;
use yii\base\InvalidConfigException;

trait TenantScopeTrait
{
    /**
     * Override find() to automatically scope queries by tenant_id.
     * PlatformAdmin operations that need cross-tenant access must use findUnscoped().
     */
    public static function find(): ActiveQuery
    {
        $tenantId = static::resolveCurrentTenantId();

        if ($tenantId === null) {
            throw new InvalidConfigException(
                "Tenant context is required to query " . static::tableName() .
                ". Use findUnscoped() for cross-tenant access."
            );
        }

        return parent::find()->andWhere([static::tableName() . ".tenant_id" => $tenantId]);
    }

    /**
     * Unscoped find for PlatformAdmin operations only.
     * Must be explicitly called → never the default.
     */
    public static function findUnscoped(): ActiveQuery
    {
        return parent::find();
    }

    /**
     * Override findOne to ensure tenant scoping.
     */
    public static function findOne($condition): ?static
    {
        $tenantId = static::resolveCurrentTenantId();

        if ($tenantId === null) {
            throw new InvalidConfigException(
                "Tenant context is required to query " . static::tableName()
            );
        }

        if (is_numeric($condition)) {
            $condition = ["id" => $condition];
        }

        $condition["tenant_id"] = $tenantId;

        return parent::findOne($condition);
    }

    /**
     * Resolve the current tenant_id from the authenticated user's JWT.
     * Returns null if no tenant context is available (e.g., console commands).
     */
    private static function resolveCurrentTenantId(): ?int
    {
        // In web context, extract from authenticated user's JWT claims
        if (Yii::$app instanceof \yii\web\Application) {
            $identity = Yii::$app->user->getIdentity();
            if ($identity !== null && isset($identity->tenant_id)) {
                return (int) $identity->tenant_id;
            }
            return null;
        }

        // In console context, tenant must be set explicitly
        if (isset(Yii::$app->params["tenantId"])) {
            return (int) Yii::$app->params["tenantId"];
        }

        return null;
    }

    /**
     * Ensure tenant_id is set before saving.
     */
    public function beforeSave($insert): bool
    {
        if (!parent::beforeSave($insert)) {
            return false;
        }

        if ($insert && empty($this->tenant_id)) {
            $tenantId = static::resolveCurrentTenantId();
            if ($tenantId !== null) {
                $this->tenant_id = $tenantId;
            }
        }

        return true;
    }
}
```

### Usage in Models

```php
namespace common\models;

use yii\db\ActiveRecord;
use yii\behaviors\TimestampBehavior;
use common\components\TenantScopeTrait;

/**
 * @property int $id
 * @property int $tenant_id
 * @property string $name
 * @property string $slug
 */
class Category extends ActiveRecord
{
    use TenantScopeTrait;

    public static function tableName(): string
    {
        return "{{%categories}}";
    }

    // ... rules, behaviors, etc.
}
```

---

## 3. Query Safety Rules

### 3.1 Default Queries Are Always Scoped

With `TenantScopeTrait`, the standard `find()` automatically filters by tenant:

```php
// Automatically scoped to the current tenant
$categories = Category::find()->all();
// SQL: SELECT * FROM categories WHERE tenant_id = :currentTenantId

$category = Category::findOne(42);
// SQL: SELECT * FROM categories WHERE id = 42 AND tenant_id = :currentTenantId
```

### 3.2 Never Bypass Scoping Without Justification

`findUnscoped()` exists ONLY for:
- PlatformAdmin cross-tenant reporting
- Console commands that process all tenants (e.g., scheduler, archiver)
- Migration data operations

```php
// PlatformAdmin: list all categories across tenants
if ($user->is_platform_admin) {
    $allCategories = Category::findUnscoped()
        ->with("tenant")
        ->all();
}
```

### 3.3 Relations Inherit Scoping

When defining relations, the tenant_id filter carries through:

```php
// In Item model
public function getOwner(): ActiveQuery
{
    return $this->hasOne(Owner::class, ["id" => "owner_id"]);
}

// This is safe → the parent item is already tenant-scoped,
// and the FK join inherently limits to the same tenant's data.
```

However, if you query a relation independently, scoping still applies:

```php
// This is automatically scoped
$owner = Owner::findOne($ownerId);
```

### 3.4 Console Commands Must Set Tenant Context

Console workers processing tenant data must explicitly set the tenant context:

```php
// In a console command or queue job
public function execute($queue): void
{
    // Set tenant context for this job
    Yii::$app->params["tenantId"] = $this->tenantId;

    // Now all TenantScopeTrait queries will use this tenant_id
    $item = Item::findOne($this->itemId);

    // ... process the item

    // Clean up
    unset(Yii::$app->params["tenantId"]);
}
```

### 3.5 Bulk Operations Must Be Tenant-Scoped

```php
// GOOD → updateAll with tenant_id
ExampleModel::updateAll(
    ["status" => self::STATUS_ARCHIVED],
    [
        "AND",
        ["tenant_id" => $tenantId],
        ["status" => self::STATUS_PUBLISHED],
        ["<", "published_at_utc", $archiveThreshold],
    ]
);

// BAD → updateAll without tenant_id (affects ALL tenants!)
ExampleModel::updateAll(
    ["status" => self::STATUS_ARCHIVED],
    ["<", "published_at_utc", $archiveThreshold]
);
```

### 3.6 deleteAll Is Prohibited on Tenant Tables

Per best practices, data is archived, not deleted. If you must delete (e.g., cleanup during testing), always include `tenant_id`:

```php
// Only in test fixtures → never in production code
Category::deleteAll(["tenant_id" => $testTenantId]);
```

---

## 4. JWT Token & Tenant Context

### 4.1 Token Structure

JWT access tokens embed:
```json
{
  "user_id": 123,
  "tenant_id": 456,
  "role": "editor",
  "exp": 1713100000
}
```

### 4.2 Tenant Switching

When a user switches tenants, a NEW token is issued scoped to the new tenant. The old token remains valid until expiry but carries the old `tenant_id`.

```
POST /api/v1/auth/switch-tenant
{"tenant_id": 789}
→ new JWT with tenant_id=789
```

### 4.3 Never Trust Client-Provided tenant_id

The `tenant_id` for all operations comes from the JWT, not from request parameters:

```php
// GOOD → tenant_id from authenticated identity
$tenantId = Yii::$app->user->identity->tenant_id;

// BAD → tenant_id from request body (spoofable!)
$tenantId = Yii::$app->request->post("tenant_id");
```

---

## 5. Database Indexes for Tenant Queries

Every tenant-owned table MUST have:

1. **Single-column index** on `tenant_id`:
   ```php
   $this->createIndex("idx-{table}-tenant_id", "{{%{table}}}", "tenant_id");
   ```

2. **Composite indexes** for frequently queried combinations:
   ```php
   // tenant_id + status (common filter)
   $this->createIndex("idx-items-tenant_id-status",
       "{{%items}}", ["tenant_id", "status"]);

   // tenant_id + slug (unique per tenant)
   $this->createIndex("idx-categories-tenant_id-slug",
       "{{%categories}}", ["tenant_id", "slug"], true);
   ```

3. **Foreign key** to `tenants` table:
   ```php
   $this->addForeignKey("fk-{table}-tenant_id",
       "{{%{table}}}", "tenant_id",
       "{{%tenants}}", "id",
       "CASCADE", "CASCADE");
   ```

---

## 6. PlatformAdmin Access

`PlatformAdmin` users can access data across tenants. This access is:
- Explicitly opted into via `findUnscoped()`
- Always audit-logged with the `is_impersonation` flag
- Never the default → requires deliberate code paths

```php
// PlatformAdmin controller action
public function actionCrossTenantReport(): array
{
    $this->requirePlatformAdmin();

    $counts = ExampleModel::findUnscoped()
        ->select(["tenant_id", "COUNT(*) as total"])
        ->groupBy("tenant_id")
        ->asArray()
        ->all();

    AuditLog::logImpersonation("cross_tenant_report", [
        "admin_user_id" => Yii::$app->user->id,
    ]);

    return $this->buildSuccessResponse($counts);
}
```

---

## 7. Testing Tenant Isolation

Every tenant-scoped model MUST have tests that verify isolation:

```php
public function testCannotAccessOtherTenantData(ApiTester $I): void
{
    // Create data for tenant 1
    $I->haveInDatabase("categories", [
        "id" => 1,
        "tenant_id" => 1,
        "name" => "Tenant 1 Category",
        "slug" => "t1-cat",
    ]);

    // Create data for tenant 2
    $I->haveInDatabase("categories", [
        "id" => 2,
        "tenant_id" => 2,
        "name" => "Tenant 2 Category",
        "slug" => "t2-cat",
    ]);

    // Authenticate as tenant 1 user
    $I->amBearerAuthenticated($tenant1Token);

    // Should only see tenant 1's data
    $I->sendGET("/v1/categories");
    $I->seeResponseContainsJson(["name" => "Tenant 1 Category"]);
    $I->dontSeeResponseContainsJson(["name" => "Tenant 2 Category"]);

    // Should not be able to access tenant 2's record by ID
    $I->sendGET("/v1/categories/2");
    $I->seeResponseCodeIs(404);
}

public function testCannotModifyOtherTenantData(ApiTester $I): void
{
    $I->amBearerAuthenticated($tenant1Token);

    // Attempt to update a tenant 2 record
    $I->sendPUT("/v1/categories/2", ["name" => "Hijacked"]);
    $I->seeResponseCodeIs(404);

    // Verify data unchanged
    $I->seeInDatabase("categories", [
        "id" => 2,
        "name" => "Tenant 2 Category",
    ]);
}
```

---

## 8. Common Pitfalls

### Pitfall 1: Forgetting tenant scope in `updateAll` / `deleteAll`
These static methods do NOT go through `find()`, so the trait's automatic scoping does not apply. Always include `tenant_id` manually.

### Pitfall 2: Using raw IDs without tenant verification
```php
// BAD → finds by ID only, no tenant check
$item = Item::findOne($itemId);

// GOOD → if Item uses TenantScopeTrait, findOne auto-adds tenant_id
$item = Item::findOne($itemId);
```

### Pitfall 3: Leaking data in error messages
```php
// BAD → reveals existence of records in other tenants
throw new ForbiddenHttpException("You cannot access item #" . $id);

// GOOD → consistent 404 regardless of whether record exists in another tenant
throw new NotFoundHttpException("Item not found.");
```

### Pitfall 4: Console commands without tenant context
```php
// BAD → will throw InvalidConfigException
$categories = Category::find()->all();

// GOOD → set context first
Yii::$app->params["tenantId"] = $tenantId;
$categories = Category::find()->all();
```

### Pitfall 5: Aggregate queries leaking across tenants
```php
// BAD → counts ALL tenants' data
$total = ExampleModel::find()->count(); // double-check trait scopes this

// GOOD → explicit and clear
$total = ExampleModel::find()
    ->where(["tenant_id" => $tenantId])
    ->count();
```

---

## 9. Checklist for New Tenant-Scoped Features

- [ ] Migration creates `tenant_id BIGINT UNSIGNED NOT NULL` column
- [ ] Migration adds foreign key to `tenants` table
- [ ] Migration adds index on `tenant_id` (single and composite)
- [ ] Model uses `TenantScopeTrait`
- [ ] Model has `tenant_id` in `rules()` as `required` and `integer`
- [ ] Controller never reads `tenant_id` from request body
- [ ] Any `updateAll()` / `deleteAll()` calls include `tenant_id`
- [ ] Tests verify cross-tenant data cannot be read
- [ ] Tests verify cross-tenant data cannot be modified
- [ ] Error responses use 404 (not 403) to avoid revealing record existence
