# API Models Reference

## Confirmed Models

This snapshot documents the confirmed WiserContent models, services, traits, and queue jobs reflected in the current PRD and companion docs.

All models live in `src/common/models/`. All IDs are `BIGINT UNSIGNED`. Timestamps are Unix integers via `TimestampBehavior`.

---

## Phase 1 Models

### Tenant

**File:** `src/common/models/Tenant.php`
**Table:** `tenants`
**Tenant-scoped:** No (IS the tenant)

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| name | string | Tenant display name |
| slug | string | URL-safe unique identifier |
| timezone | string | IANA timezone (default: UTC) |
| status | string | active, inactive, suspended |
| mfa_required | bool | Whether MFA is enforced for this tenant |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Constants:** `STATUS_ACTIVE`, `STATUS_INACTIVE`, `STATUS_SUSPENDED`
**Relations:** `getUserTenants()` -> UserTenant[]
**Methods:** `isActive(): bool`

---

### User

**File:** `src/common/models/User.php`
**Table:** `users`
**Tenant-scoped:** No (global, multi-tenant via user_tenants)
**Implements:** `IdentityInterface`

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| email | string | Unique email address |
| password_hash | string | Bcrypt password hash |
| status | string | active, inactive, pending |
| is_platform_admin | bool | Platform-level super-admin flag |
| mfa_secret | string/null | Encrypted TOTP secret |
| mfa_enabled | bool | Whether MFA is enabled |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Transient properties:** `activeTenantId: ?int`, `activeRole: ?string` (from JWT, not persisted)
**Constants:** `STATUS_ACTIVE`, `STATUS_INACTIVE`, `STATUS_PENDING`
**Relations:** `getUserTenants()` -> UserTenant[], `getTenants()` -> Tenant[]
**Methods:** `setPassword()`, `validatePassword()`, `getDecryptedMfaSecret()`, `setEncryptedMfaSecret()`, `findByEmail()`, `isPlatformAdmin()`, `getRoleForTenant()`, `isActive()`

---

### UserTenant

**File:** `src/common/models/UserTenant.php`
**Table:** `user_tenants`
**Tenant-scoped:** No (join table, would create circular dependency)

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| user_id | int | FK to users |
| tenant_id | int | FK to tenants |
| role | string | owner, admin, editor, viewer |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Constants:** `ROLE_OWNER`, `ROLE_ADMIN`, `ROLE_EDITOR`, `ROLE_VIEWER`, `ROLES`
**Relations:** `getUser()` -> User, `getTenant()` -> Tenant
**Methods:** `canApprove(): bool`, `isAdmin(): bool`

---

### UserInvitation

**File:** `src/common/models/UserInvitation.php`
**Table:** `user_invitations`
**Tenant-scoped:** Yes (TenantScopeTrait)

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| email | string | Invitee email |
| tenant_id | int | FK to tenants |
| role | string | Role to assign on acceptance |
| token_hash | string | SHA-256 hash of invitation token |
| expires_at | int | Expiration Unix timestamp |
| accepted_at | int/null | Acceptance Unix timestamp |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Constants:** `EXPIRATION_SECONDS = 604800` (7 days)
**Relations:** `getTenant()` -> Tenant
**Methods:** `isExpired()`, `isAccepted()`, `generateToken()`, `hashToken()`

---

### PasswordReset

**File:** `src/common/models/PasswordReset.php`
**Table:** `password_resets`
**Tenant-scoped:** No (user-referenced, global)

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| user_id | int | FK to users |
| token_hash | string | SHA-256 hash |
| expires_at | int | Expiration Unix timestamp |
| used_at | int/null | Usage Unix timestamp |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Methods:** `isExpired()`, `isUsed()`, `isValid()`, `generateToken()`, `hashToken()`

---

### AiProvider

**File:** `src/common/models/AiProvider.php`
**Table:** `ai_providers`
**Tenant-scoped:** No (global enum)

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| name | string | Display name |
| slug | string | Unique slug identifier |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Constants:** `SLUG_ANTHROPIC`, `SLUG_OPENAI`, `SLUG_GOOGLE`, `SLUG_XAI`
**Methods:** `findBySlug()`

---

### RefreshToken

**File:** `src/common/models/RefreshToken.php`
**Table:** `refresh_tokens`
**Tenant-scoped:** No (user-referenced)

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| user_id | int | FK to users |
| token_hash | string | SHA-256 hash |
| expires_at | int | Expiration Unix timestamp |
| revoked_at | int/null | Revocation Unix timestamp |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Constants:** `EXPIRATION_SECONDS = 2592000` (30 days)
**Methods:** `isExpired()`, `isRevoked()`, `isValid()`, `revoke()`, `generateToken()`, `hashToken()`, `findValidByHash()`

---

## Phase 2 Models

### ContentType (Component)

**File:** `src/common/components/ContentType.php`
**Type:** Final class (code-level enum, not ActiveRecord)

| Constant | Value |
|---|---|
| HOW_TO | how_to |
| LISTICLE | listicle |
| EXPLAINER | explainer |
| NEWS | news |
| OPINION | opinion |
| CASE_STUDY | case_study |
| INTERVIEW | interview |
| REVIEW | review |
| COMPARISON | comparison |
| GUIDE | guide |

**Methods:** `all(): string[]`, `isValid(string): bool`, `labels(): array`

---

### AuditLog

**File:** `src/common/models/AuditLog.php`
**Table:** `audit_log`
**Tenant-scoped:** No (queried cross-tenant by PlatformAdmin)

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| tenant_id | int/null | Tenant context (auto-resolved) |
| user_id | int/null | User who performed the action |
| action | string | Action type (create, update, delete, etc.) |
| entity_type | string | Entity type (category, writer, etc.) |
| entity_id | int/null | Entity primary key |
| old_values | string/null | JSON of previous values |
| new_values | string/null | JSON of new values |
| ip_address | string/null | Client IP address |
| user_agent | string/null | Client user agent |
| created_at | int | Unix timestamp |

**Constants:** `ACTION_CREATE`, `ACTION_UPDATE`, `ACTION_DELETE`, `ACTION_LOGIN`, `ACTION_LOGOUT`, `ACTION_PASSWORD_RESET`, `ACTION_MFA_ENABLE`, `ACTION_MFA_DISABLE`, `ACTION_KEY_ROTATION`, `ACTION_IMPERSONATE`, `ACTION_APPROVE`, `ACTION_REJECT`
**Methods:** `log(action, entityType, entityId, oldValues, newValues)`: static helper with auto-resolved context

---

### Category

**File:** `src/common/models/Category.php`
**Table:** `categories`
**Tenant-scoped:** Yes (TenantScopeTrait)
**Behaviors:** TimestampBehavior, AuditBehavior

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| tenant_id | int | FK to tenants |
| name | string | Category name |
| slug | string | URL-safe slug (unique per tenant) |
| description | string/null | Optional description |
| status | string | active, inactive |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Constants:** `STATUS_ACTIVE`, `STATUS_INACTIVE`
**Relations:** `getTenant()` -> Tenant
**Methods:** `isActive(): bool`

---

### TenantAiKey

**File:** `src/common/models/TenantAiKey.php`
**Table:** `tenant_ai_keys`
**Tenant-scoped:** Yes (TenantScopeTrait)
**Behaviors:** TimestampBehavior, AuditBehavior

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| tenant_id | int | FK to tenants |
| ai_provider_id | int | FK to ai_providers |
| api_key_encrypted | string | AES-256 encrypted API key |
| model_default | string/null | Default model identifier |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Relations:** `getTenant()` -> Tenant, `getAiProvider()` -> AiProvider
**Methods:** `getDecryptedApiKey(): ?string`, `setEncryptedApiKey(?string): void`

---

### TenantLangfuseConfig

**File:** `src/common/models/TenantLangfuseConfig.php`
**Table:** `tenant_langfuse_configs`
**Tenant-scoped:** Yes (TenantScopeTrait)
**Behaviors:** TimestampBehavior, AuditBehavior

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| tenant_id | int | FK to tenants (unique: one per tenant) |
| host | string | Langfuse host URL |
| public_key | string | Langfuse public key |
| secret_key_encrypted | string | AES-256 encrypted secret key |
| project_name | string | Langfuse project name |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Relations:** `getTenant()` -> Tenant
**Methods:** `getDecryptedSecretKey(): ?string`, `setEncryptedSecretKey(?string): void`

---

### Writer

**File:** `src/common/models/Writer.php`
**Table:** `writers`
**Tenant-scoped:** Yes (TenantScopeTrait)
**Behaviors:** TimestampBehavior, AuditBehavior

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| tenant_id | int | FK to tenants |
| name | string | Writer persona name |
| ai_provider_id | int | FK to ai_providers |
| model | string | AI model identifier |
| langfuse_prompt_label | string | Langfuse prompt label |
| personality_metadata | string/null | JSON personality config |
| category_assignments | string/null | JSON array of category IDs |
| content_type_assignments | string/null | JSON array of content type slugs |
| is_default | bool | Default writer for tenant |
| status | string | active, inactive |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Relations:** `getTenant()` -> Tenant, `getAiProvider()` -> AiProvider
**Methods:** `getPersonalityMetadataArray(): array`, `getCategoryAssignmentIds(): array`, `getContentTypeAssignmentSlugs(): array`, `isActive(): bool`
**Note:** `beforeSave()` ensures at most one `is_default=true` per tenant

---

### Reviser

**File:** `src/common/models/Reviser.php`
**Table:** `revisers`
**Tenant-scoped:** Yes (TenantScopeTrait)
**Behaviors:** TimestampBehavior, AuditBehavior

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| tenant_id | int | FK to tenants |
| name | string | Reviser persona name |
| ai_provider_id | int | FK to ai_providers |
| model | string | AI model identifier |
| langfuse_prompt_label | string | Langfuse prompt label |
| metadata | string/null | JSON metadata config |
| is_default | bool | Default reviser for tenant |
| status | string | active, inactive |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Relations:** `getTenant()` -> Tenant, `getAiProvider()` -> AiProvider
**Methods:** `getMetadataArray(): array`, `isActive(): bool`
**Note:** `beforeSave()` ensures at most one `is_default=true` per tenant

---

### PublishTarget

**File:** `src/common/models/PublishTarget.php`
**Table:** `publish_targets`
**Tenant-scoped:** Yes (TenantScopeTrait)
**Behaviors:** TimestampBehavior, AuditBehavior

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| tenant_id | int | FK to tenants |
| name | string | Target name |
| webhook_url | string | Webhook URL |
| auth_header_encrypted | string/null | AES-256 encrypted auth header |
| payload_template | string | JSON payload template with placeholders |
| active | bool | Whether the target is active |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Relations:** `getTenant()` -> Tenant
**Methods:** `getDecryptedAuthHeader(): ?string`, `setEncryptedAuthHeader(?string): void`, `isActive(): bool`

---

### UsageCounter

**File:** `src/common/models/UsageCounter.php`
**Table:** `usage_counters`
**Tenant-scoped:** Yes (TenantScopeTrait)
**Behaviors:** TimestampBehavior

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| tenant_id | int | FK to tenants |
| year_month | string | Format: YYYY-MM |
| articles_generated | int | Count of articles generated |
| articles_published | int | Count of articles published |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Methods:** `incrementGenerated(int tenantId, string timezone): void`, `incrementPublished(int tenantId, string timezone): void`, `findOrCreate(int tenantId, string yearMonth): self`

---

## Behaviors & Traits

### AuditBehavior

**File:** `src/common/behaviors/AuditBehavior.php`
**Attaches to:** Any ActiveRecord that needs audit logging

Automatically logs `afterInsert`, `afterUpdate`, `afterDelete` events to `audit_log`. Captures dirty attributes on update, full attributes on insert/delete. Masks sensitive fields (`password_hash`, `mfa_secret`, `api_key_encrypted`, etc.) with `[REDACTED:...xxxx]`.

**Config:** `auditEntityType`: entity type string for audit entries

---

### CursorPaginationTrait

**File:** `src/common/components/CursorPaginationTrait.php`
**Used by:** All list-action controllers

Provides `paginateQuery(ActiveQuery, ?string $cursor, int $limit = 20): array{items, next_cursor}`. Uses base64-encoded `id` as cursor. Orders by `id DESC`. Fetches `limit + 1` rows to detect `has_more`.

---

### TenantScopeTrait

**File:** `src/common/components/TenantScopeTrait.php`
**Used by:** All tenant-owned models

Automatically applies `tenant_id` filter to all `find()` queries based on the authenticated user's active tenant. Provides `findUnscoped()` for cross-tenant queries (PlatformAdmin, console).

---

## Phase 3 Models

### BriefApprovalBatch

**File:** `src/common/models/BriefApprovalBatch.php`
**Table:** `brief_approval_batches`
**Tenant-scoped:** Yes (TenantScopeTrait)

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| tenant_id | int | FK → tenants |
| name | string | Batch name |
| month | string | YYYY-MM format |
| approved_by | int\|null | FK → users |
| approved_at | int\|null | Unix timestamp |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Relations:** tenant, approvedByUser, briefs

---

### ContentBrief

**File:** `src/common/models/ContentBrief.php`
**Table:** `content_briefs`
**Tenant-scoped:** Yes (TenantScopeTrait)

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| tenant_id | int | FK → tenants |
| category_id | int\|null | FK → categories |
| title | string | Brief title (max 512) |
| content_type | string | Content type slug |
| keywords | string\|null | JSON array of keywords |
| source | string | manual, alsoasked, keyword_research |
| source_payload | string\|null | JSON source data |
| status | string | draft, approved, rejected |
| approved_by | int\|null | FK → users |
| approved_at | int\|null | Unix timestamp |
| brief_approval_batch_id | int\|null | FK → brief_approval_batches |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Relations:** tenant, category, approvedByUser, approvalBatch, contentItems
**Helpers:** `getKeywordsArray()`, `isDraft()`, `isApproved()`

---

### ContentItem

**File:** `src/common/models/ContentItem.php`
**Table:** `content_items`
**Tenant-scoped:** Yes (TenantScopeTrait)

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| tenant_id | int | FK → tenants |
| brief_id | int | FK → content_briefs |
| parent_content_id | int\|null | Self-referencing FK |
| status | string | 10-state machine |
| selected_draft_id | int\|null | FK → content_drafts |
| approved_by | int\|null | FK → users |
| approved_at | int\|null | Unix timestamp |
| scheduled_at_utc | int\|null | Scheduled publish time |
| published_at_utc | int\|null | Actual publish time |
| publish_target_id | int\|null | FK → publish_targets |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Statuses:** draft, generating, written, revised, pending_approval, approved, scheduled, published, archived, generation_failed, publish_failed

**Relations:** tenant, brief, parentContent, childContent, selectedDraft, drafts, revisionRounds, approvalEvents, publishAttempts, approvedByUser, publishTarget

---

### ContentDraft

**File:** `src/common/models/ContentDraft.php`
**Table:** `content_drafts`
**Tenant-scoped:** No (child of ContentItem)

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| content_item_id | int | FK → content_items |
| writer_id | int\|null | FK → writers |
| version | int | Draft version number |
| body | string\|null | LONGTEXT content body |
| metadata | string\|null | JSON metadata |
| status | string | pending, completed, failed, superseded |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Relations:** contentItem, writer
**Helpers:** `getMetadataArray()`

---

### RevisionRound

**File:** `src/common/models/RevisionRound.php`
**Table:** `revision_rounds`
**Tenant-scoped:** No (child of ContentItem)

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| content_item_id | int | FK → content_items |
| reviser_id | int\|null | FK → revisers |
| from_draft_id | int | FK → content_drafts |
| to_draft_id | int\|null | FK → content_drafts |
| notes | string\|null | Revision notes |
| langfuse_trace_id | string\|null | Langfuse trace ID |
| created_at | int | Unix timestamp |
| updated_at | int | Unix timestamp |

**Relations:** contentItem, reviser, fromDraft, toDraft

---

### ApprovalEvent

**File:** `src/common/models/ApprovalEvent.php`
**Table:** `approval_events`
**Tenant-scoped:** No (child of ContentItem)

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| content_item_id | int | FK → content_items |
| user_id | int | FK → users |
| action | string | approve, reject, edit, send_back |
| target_stage | string\|null | Stage to send back to |
| comment | string\|null | Reviewer comment |
| created_at | int | Unix timestamp |

**Relations:** contentItem, user

---

### PublishAttempt

**File:** `src/common/models/PublishAttempt.php`
**Table:** `publish_attempts`
**Tenant-scoped:** No (child of ContentItem)

| Property | Type | Description |
|---|---|---|
| id | int | Primary key |
| content_item_id | int | FK → content_items |
| publish_target_id | int | FK → publish_targets |
| request_payload | string\|null | Webhook request body |
| response_code | int\|null | HTTP response code |
| response_body | string\|null | Webhook response body |
| attempted_at | int | Unix timestamp |
| created_at | int | Unix timestamp |

**Relations:** contentItem, publishTarget
**Helpers:** `isSuccessful()`

---

## Phase 3 Services

### ContentStateMachine

**File:** `src/common/services/ContentStateMachine.php`

Manages all content item status transitions with validation and side effects.

| Method | Description |
|---|---|
| `canTransition(ContentItem, string)` | Check if transition is valid |
| `transition(ContentItem, string)` | Execute status transition |
| `approve(ContentItem, userId, ?draftId)` | Approve with ApprovalEvent |
| `reject(ContentItem, userId, comment, ?targetStage)` | Reject with send_back event |
| `schedule(ContentItem, scheduledAtUtc, publishTargetId)` | Schedule for publishing |
| `publish(ContentItem)` | Mark as published |
| `getAvailableTransitions(ContentItem)` | List valid target statuses |

### WriterAssignmentService

**File:** `src/common/services/WriterAssignmentService.php`

Matches briefs to writers by category and content type assignments.

| Method | Description |
|---|---|
| `findMatchingWriters(tenantId, ?categoryId, contentType)` | Returns up to 2 matching writers |

---

## Phase 3 Queue Jobs

### GenerateDraftJob

**File:** `src/common/jobs/GenerateDraftJob.php`
**TTR:** 300s | **Retries:** 3

Creates a ContentDraft and calls the AI provider (placeholder for Phase 4).

### RunReviserJob

**File:** `src/common/jobs/RunReviserJob.php`
**TTR:** 300s | **Retries:** 3

Creates a RevisionRound and revised ContentDraft.

### PublishContentJob

**File:** `src/common/jobs/PublishContentJob.php`
**TTR:** 120s | **Retries:** 4

Fires webhook, logs PublishAttempt, transitions to published/publish_failed.

## Proposed Models

No proposed models are tracked in this frozen snapshot. Add future model ideas here until they are confirmed in the PRD.

## Model Relationships

- Tenant-scoped resources belong to a single tenant and must enforce `tenant_id` filtering.
- Briefs create content items, content items own drafts and revision rounds, and publish attempts belong to content items.
- Writer and reviser configuration is tenant-scoped and feeds the content generation pipeline.
