# Changelog

All notable changes to the WiserContent API will be documented in this file.

## [0.3.0] - 2026-04-13

### Added
- **Content Pipeline:** Full brief → generation → revision → approval → scheduling → publishing workflow
- **Migrations:** brief_approval_batches, content_briefs, content_items, content_drafts, revision_rounds, approval_events, publish_attempts (all utf8mb4_unicode_ci)
- **Models:** BriefApprovalBatch, ContentBrief, ContentItem, ContentDraft, RevisionRound, ApprovalEvent, PublishAttempt
- **Services:** ContentStateMachine (10-state workflow with transition validation), WriterAssignmentService (category + content type matching)
- **Queue Jobs:** GenerateDraftJob, RunReviserJob, PublishContentJob: all with RetryableJobInterface
- **Controllers:** BriefController (CRUD + approve/reject/batch-approve + AlsoAsked/keyword-research import), ContentController (generate/select-draft/edit/approve/reject/schedule/publish/cancel), DraftController (list/view), RevisionController (trigger/history)
- **URL Rules:** 25 new RESTful routes for content pipeline
- **CategoryController:** Delete guard: blocks deletion when category is referenced by briefs

### Added (Tests)
- **API Tests:** BriefCrudCest (11 tests), ContentPipelineCest (16 tests), DraftCest (5 tests), RevisionCest (8 tests), AuditLogCest (3 new tests for brief/content audit entries)
- **AuthenticateCest:** Seed `app` table in `_before()` for legacy auth tests

### Fixed
- **Writer/Reviser models:** Handle MySQL JSON columns returning PHP arrays instead of strings in `getCategoryAssignmentIds()`, `getContentTypeAssignmentSlugs()`, `getPersonalityMetadataArray()`, `getMetadataArray()`
- **ContentController:** Cast all integer fields in `formatContentItem()` to ensure consistent JSON types
- **UserController:** Cast invitation `id` and `expires_at` to int in create response
- **TenantCrudCest:** Use timestamp-based slug to avoid collision from API-created tenants

### Changed
- All migrations now specify `CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ENGINE=InnoDB`
- DB connection charset updated from `utf8` to `utf8mb4` in all environments

## [0.2.0] - 2026-04-13

### Added
- **Cursor Pagination:** CursorPaginationTrait for all list endpoints (base64-encoded ID cursors, ORDER BY id DESC)
- **Content Types:** ContentType enum component with 10 platform-wide types (how_to, listicle, explainer, etc.)
- **Audit Logging:** AuditLog model + AuditBehavior for automatic insert/update/delete audit trails with sensitive field masking
- **Migrations:** content_types, audit_log, categories, tenant_ai_keys, tenant_langfuse_configs, writers, revisers, publish_targets, usage_counters
- **Models:** Category, TenantAiKey, TenantLangfuseConfig, Writer, Reviser, PublishTarget, UsageCounter
- **Encrypted Fields:** TenantAiKey.api_key_encrypted, TenantLangfuseConfig.secret_key_encrypted, PublishTarget.auth_header_encrypted: all via EncryptionService
- **CRUD Controllers:** TenantController, UserController, CategoryController, AiKeyController, LangfuseConfigController, WriterController, ReviserController, PublishTargetController, UsageController
- **URL Rules:** RESTful routes for all 9 new controllers
- **API Tests:** CategoryCrudCest, AiKeyCrudCest, LangfuseConfigCest, WriterCrudCest, ReviserCrudCest, PublishTargetCrudCest, TenantCrudCest, UserCrudCest, UsageCest, AuditLogCest
- **Documentation:** Full request/response payloads in api-endpoints.md, model reference in api-models.md, controller reference in api-controllers.md
- **Base Controller Helpers:** getQueryParam(), setResponseStatus(), getBodyParams() for PHPStan-safe request/response access

## [0.1.0] - 2026-04-13

### Added
- **Infrastructure:** PHP 8.2+ requirement, PHPStan Level 8, PHPCS/PHPCBF
- **Encryption:** AES-256 EncryptionService component for sensitive field encryption
- **Tenant Isolation:** TenantScopeTrait for automatic row-level tenant_id scoping
- **Migrations:** tenants, users, user_tenants, user_invitations, password_resets, ai_providers, refresh_tokens
- **Models:** Tenant, User, UserTenant, UserInvitation, PasswordReset, AiProvider, RefreshToken
- **JWT Auth:** JwtService (15-min access tokens, 30-day refresh), JwtBearerAuth, TenantFilter
- **Auth Endpoints:** POST /v1/auth/login, POST /v1/auth/refresh, POST /v1/auth/switch-tenant, GET /v1/auth/me
- **Legacy Auth:** Preserved POST /v1/authenticate for backward compatibility
- **API Tests:** AuthLoginCest, AuthRefreshCest, AuthSwitchTenantCest, AuthMeCest, TenantIsolationCest
- **Documentation:** AGENTS.md, YII2-BEST-PRACTICES.md, YII2-TENANT-FILTERING.md, DEVELOPMENT-WORKFLOW.md
