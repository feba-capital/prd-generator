# Yii2 Best Practices

**Applies to:** All PHP code in `src/` (excluding `vendor/`)
**Standard:** PSR-2, PHPCompatibility 8.2+, PHPStan Level 8

---

## 1. Project Architecture

This project uses the **Yii2 Advanced Template** with two applications:

| Application | Purpose | Entry Point |
|---|---|---|
| `api` | REST API (HTTP) | `src/api/web/index.php` |
| `console` | Workers, scheduler, migrations, CLI commands | `src/yii` |
| `common` | Shared models, components, helpers, jobs | (library, no entry point) |

### Namespace Mapping

```
api\         → src/api/
console\     → src/console/
common\      → src/common/
```

---

## 2. Models (ActiveRecord)

### 2.1 One Model Per Table

Each database table has exactly one ActiveRecord model in `common/models/`. No table should be accessed by raw queries or ad-hoc ActiveRecord subclasses.

### 2.2 Required Structure

Every model MUST include:

```php
namespace common\models;

use yii\db\ActiveRecord;
use yii\behaviors\TimestampBehavior;

/**
 * @property int $id
 * @property string $name
 * @property int $created_at
 * @property int $updated_at
 */
class ExampleModel extends ActiveRecord
{
    // 1. Constants
    public const STATUS_ACTIVE = "active";
    public const STATUS_INACTIVE = "inactive";

    // 2. Table name
    public static function tableName(): string
    {
        return "{{%example_models}}";
    }

    // 3. Validation rules
    public function rules(): array
    {
        return [
            [["name"], "required"],
            [["name"], "string", "max" => 255],
            [["status"], "in", "range" => [self::STATUS_ACTIVE, self::STATUS_INACTIVE]],
        ];
    }

    // 4. Attribute labels
    public function attributeLabels(): array
    {
        return [
            "id" => "ID",
            "name" => "Name",
        ];
    }

    // 5. Behaviors
    public function behaviors(): array
    {
        return [
            TimestampBehavior::class,
        ];
    }

    // 6. Relations
    // 7. Finders (static query methods)
    // 8. Business logic methods
}
```

### 2.3 PHPDoc Property Annotations

Every model MUST declare `@property` annotations for all database columns. This enables PHPStan Level 8 analysis and IDE autocompletion.

```php
/**
 * @property int $id
 * @property int $tenant_id
 * @property string $title
 * @property string $content_type
 * @property array $keywords  ← JSON columns use array type
 * @property string $status
 * @property int|null $approved_by  ← nullable columns use union types
 * @property int|null $approved_at
 * @property int $created_at
 * @property int $updated_at
 *
 * @property-read Tenant $tenant  ← read-only relations
 * @property-read Category $category
 */
```

### 2.4 Validation Rules

- Validate **all** attributes that accept user input.
- Use `required` for non-nullable columns.
- Use `integer` for all ID and timestamp fields.
- Use `in` with constants for enum/status fields.
- Use `unique` with `targetAttribute` for composite uniqueness (e.g., `tenant_id` + `slug`).
- Use `exist` for foreign key validation.

```php
public function rules(): array
{
    return [
        [["tenant_id", "category_id", "title", "content_type"], "required"],
        [["tenant_id", "category_id", "approved_by"], "integer"],
        [["title"], "string", "max" => 255],
        [["content_type"], "in", "range" => self::CONTENT_TYPES],
        [["status"], "in", "range" => [
            self::STATUS_DRAFT,
            self::STATUS_APPROVED,
            self::STATUS_REJECTED,
        ]],
        [["category_id"], "exist",
            "targetClass" => Category::class,
            "targetAttribute" => ["category_id" => "id", "tenant_id" => "tenant_id"],
        ],
    ];
}
```

### 2.5 Relations

- Always define relations using Yii2's `hasOne()` / `hasMany()`.
- Name relation methods with `get` prefix: `getTenant()`, `getCategory()`, `getDrafts()`.
- Always declare the `@property-read` annotation for relations.
- Use `with()` for eager loading in queries to avoid N+1.

```php
public function getTenant(): \yii\db\ActiveQuery
{
    return $this->hasOne(Tenant::class, ["id" => "tenant_id"]);
}

public function getDrafts(): \yii\db\ActiveQuery
{
    return $this->hasMany(ContentDraft::class, ["content_item_id" => "id"]);
}
```

### 2.6 Business Logic in Models

Models own their business logic. Controllers should not contain domain rules.

```php
// GOOD: Logic in model
public function approve(int $userId): bool
{
    $this->status = self::STATUS_APPROVED;
    $this->approved_by = $userId;
    $this->approved_at = time();
    return $this->save();
}

// BAD: Logic in controller
public function actionApprove(int $id): array
{
    $model = ContentItem::findOne($id);
    $model->status = "approved";       // Magic string
    $model->approved_by = $this->userId; // Logic in controller
    $model->approved_at = time();
    $model->save();
}
```

### 2.7 Constants Over Magic Strings

Define status values, types, and enum-like values as class constants:

```php
public const STATUS_DRAFT = "draft";
public const STATUS_WRITTEN = "written";
public const STATUS_REVISED = "revised";
public const STATUS_PENDING_APPROVAL = "pending_approval";
public const STATUS_APPROVED = "approved";
public const STATUS_SCHEDULED = "scheduled";
public const STATUS_PUBLISHED = "published";
public const STATUS_ARCHIVED = "archived";
public const STATUS_GENERATION_FAILED = "generation_failed";
public const STATUS_PUBLISH_FAILED = "publish_failed";

public const STATUSES = [
    self::STATUS_DRAFT,
    self::STATUS_WRITTEN,
    // ...
];
```

---

## 3. Controllers

### 3.1 All Controllers Extend Base

Every API controller MUST extend `api\components\Controller`:

```php
namespace api\controllers\v1;

use api\components\Controller;

class CategoryController extends Controller
{
    // ...
}
```

### 3.2 Thin Controllers

Controllers handle HTTP concerns only:
- Parse and validate input (via model `rules()`)
- Call model/service methods for business logic
- Format and return responses

```php
public function actionCreate(): array
{
    $model = new Category();
    $model->tenant_id = $this->getTenantId();
    $model->load($this->getRawParameters(), "");

    if (!$model->save()) {
        return $this->buildErrorResponse("Validation failed", $model->errors, 422);
    }

    return $this->buildSuccessResponse($model->toArray());
}
```

### 3.3 Action Naming

- `actionIndex`: list resources (GET)
- `actionView`: get single resource (GET with id)
- `actionCreate`: create resource (POST)
- `actionUpdate`: update resource (PUT/PATCH with id)
- `actionDelete`: delete resource (DELETE with id)
- Custom actions use descriptive verbs: `actionApprove`, `actionSchedule`, `actionTriggerGeneration`

### 3.4 Response Format

Always use the base controller's response builders:

```php
// Success
return $this->buildSuccessResponse($data);
// → {"success": true, "data": {...}}

// Error
return $this->buildErrorResponse("Not found", [], 404);
// → {"success": false, "message": "Not found", "errors": []}
```

### 3.5 Authentication Overrides

If a specific action needs to be public (e.g., health check), override `behaviors()`:

```php
public function behaviors(): array
{
    $behaviors = parent::behaviors();
    $behaviors["authenticator"]["optional"] = ["health"];
    return $behaviors;
}
```

---

## 4. Type Safety (PHPStan Level 8)

### 4.1 Method Signatures

Every method MUST have full type declarations:

```php
// GOOD
public function findBySlug(string $slug): ?self
{
    return self::find()
        ->where(["slug" => $slug, "tenant_id" => $this->tenant_id])
        ->one();
}

// BAD — missing types
public function findBySlug($slug)
{
    return self::find()->where(["slug" => $slug])->one();
}
```

### 4.2 Property Types

Use typed properties (PHP 8.2+):

```php
class PublishService
{
    public function __construct(
        private readonly HttpClientInterface $httpClient,
        private readonly EncryptionService $encryptionService,
    ) {}
}
```

### 4.3 Nullability

- Be explicit about nullability with `?Type` or union types.
- Check for null before using potentially null values.
- Never use `@phpstan-ignore` to suppress legitimate null-safety warnings.

```php
public function getSelectedDraft(): ?ContentDraft
{
    if ($this->selected_draft_id === null) {
        return null;
    }
    return ContentDraft::findOne($this->selected_draft_id);
}
```

### 4.4 Array Shapes

For JSON columns and complex arrays, use PHPDoc array shapes:

```php
/**
 * @return array{title: string, body: string, keywords: string[], category: string}
 */
public function toPublishPayload(): array
{
    return [
        "title" => $this->title,
        "body" => $this->getSelectedDraft()->body,
        "keywords" => $this->brief->keywords,
        "category" => $this->category->name,
    ];
}
```

---

## 5. Error Handling

### 5.1 Use Yii2 Exceptions

```php
use yii\web\NotFoundHttpException;
use yii\web\ForbiddenHttpException;
use yii\web\UnprocessableEntityHttpException;

// Finding records
$model = ContentItem::findOne($id);
if ($model === null) {
    throw new NotFoundHttpException("Content item not found.");
}
```

### 5.2 Model Save Errors

Always check `save()` return value:

```php
if (!$model->save()) {
    return $this->buildErrorResponse("Validation failed", $model->errors, 422);
}
```

### 5.3 Transaction Safety

Use transactions for multi-step operations:

```php
$transaction = Yii::$app->db->beginTransaction();
try {
    $contentItem->approve($userId);
    $approvalEvent->save();
    $transaction->commit();
} catch (\Throwable $e) {
    $transaction->rollBack();
    throw $e;
}
```

---

## 6. Query Building

### 6.1 Use ActiveQuery

```php
// GOOD — ActiveQuery with tenant scoping
$items = ContentItem::find()
    ->where(["tenant_id" => $tenantId, "status" => ContentItem::STATUS_SCHEDULED])
    ->andWhere(["<=", "scheduled_at_utc", time()])
    ->orderBy(["scheduled_at_utc" => SORT_ASC])
    ->all();

// BAD — raw SQL
$items = Yii::$app->db->createCommand("SELECT * FROM content_items WHERE ...")->queryAll();
```

### 6.2 Eager Loading

Prevent N+1 queries with `with()`:

```php
$items = ContentItem::find()
    ->where(["tenant_id" => $tenantId])
    ->with(["brief", "category", "drafts", "publishTarget"])
    ->all();
```

### 6.3 Pagination

Use cursor-based pagination per the API convention:

```php
$query = ContentItem::find()
    ->where(["tenant_id" => $tenantId])
    ->orderBy(["id" => SORT_DESC])
    ->limit($limit + 1);

if ($cursor !== null) {
    $query->andWhere(["<", "id", $cursor]);
}
```

---

## 7. Behaviors & Events

### 7.1 TimestampBehavior

All models use `TimestampBehavior` (unix timestamps via `time()`):

```php
public function behaviors(): array
{
    return [
        TimestampBehavior::class,
    ];
}
```

### 7.2 Custom Behaviors

For cross-cutting concerns, create Yii2 behaviors instead of duplicating code:

```php
// AuditBehavior — attach to models that need audit logging
class AuditBehavior extends \yii\base\Behavior
{
    public function events(): array
    {
        return [
            ActiveRecord::EVENT_AFTER_INSERT => "logInsert",
            ActiveRecord::EVENT_AFTER_UPDATE => "logUpdate",
        ];
    }
}
```

---

## 8. Encryption

For sensitive fields (AI keys, Langfuse secrets, webhook auth headers):

- Use AES-256 encryption with the app-level master key from environment.
- Never log, dump, or expose plaintext values.
- Store only encrypted values in the database.
- Decrypt only at point of use (e.g., right before making an API call).

---

## 9. Code Style Quick Reference

| Rule | Standard |
|---|---|
| String quotes | Double quotes `"string"` |
| Array syntax | Short syntax `[]` only |
| Class naming | PascalCase |
| Method naming | camelCase |
| Property naming | camelCase (snake_case for DB columns) |
| Constants | UPPER_SNAKE_CASE |
| Indentation | 4 spaces |
| Line length | No hard limit (PSR2 LineLength excluded) |
| Concatenation | Spaces around `.`: `"hello" . " " . "world"` |
| Type declarations | Required on all methods |
| PHPDoc | Required for `@property` on models, optional elsewhere if types are declared |

---

## 10. Anti-Patterns to Avoid

### Do NOT use static helper classes for business logic
```php
// BAD
ContentHelper::approve($contentId, $userId);

// GOOD
$content->approve($userId);
```

### Do NOT use array configs when objects are clearer
```php
// BAD
$config = ["retries" => 3, "backoff" => "exponential"];

// GOOD — use typed properties or value objects
class RetryConfig
{
    public function __construct(
        public readonly int $retries = 3,
        public readonly string $backoff = "exponential",
    ) {}
}
```

### Do NOT catch and silently swallow exceptions
```php
// BAD
try {
    $model->save();
} catch (\Exception $e) {
    // silently ignored
}

// GOOD
if (!$model->save()) {
    Yii::error("Failed to save: " . json_encode($model->errors));
    return $this->buildErrorResponse("Save failed", $model->errors, 422);
}
```

### Do NOT use `Yii::$app` in models for request-scoped data
```php
// BAD — couples model to web context
$this->tenant_id = Yii::$app->user->identity->tenant_id;

// GOOD — pass tenant_id explicitly
$model->tenant_id = $tenantId;
```
