# API Controllers Reference

All controllers live in `src/api/controllers/v1/` and extend `api\components\Controller`.

---

## Phase 1 Controllers

### AuthController

**File:** `src/api/controllers/v1/AuthController.php`
**Route prefix:** `v1/auth`

| Action | Method | Route | Auth | Description |
|---|---|---|---|---|
| actionLogin | POST | /v1/auth/login | No | JWT login with email/password |
| actionRefresh | POST | /v1/auth/refresh | No | Rotate refresh token |
| actionSwitchTenant | POST | /v1/auth/switch-tenant | Yes | Switch active tenant |
| actionMe | GET | /v1/auth/me | Yes | Get user profile |
| actionLoginLegacy | POST | /v1/authenticate | No | Legacy App-based auth |

**Private helpers:** `issueTokens()`, `findMembership()`, `formatUser()`, `formatTenant()`

---

## Phase 2 Controllers

### TenantController

**File:** `src/api/controllers/v1/TenantController.php`
**Route prefix:** `v1/tenants`
**Traits:** `CursorPaginationTrait`

| Action | Method | Route | Auth | Role | Description |
|---|---|---|---|---|---|
| actionIndex | GET | /v1/tenants | Yes | PlatformAdmin | List all tenants (paginated) |
| actionView | GET | /v1/tenants/{id} | Yes | PlatformAdmin | View single tenant |
| actionCreate | POST | /v1/tenants | Yes | PlatformAdmin | Create new tenant |
| actionUpdate | PUT | /v1/tenants/{id} | Yes | PlatformAdmin | Update tenant |

---

### UserController

**File:** `src/api/controllers/v1/UserController.php`
**Route prefix:** `v1/users`
**Traits:** `CursorPaginationTrait`

| Action | Method | Route | Auth | Role | Description |
|---|---|---|---|---|---|
| actionIndex | GET | /v1/users | Yes | Owner/Admin | List tenant users (paginated) |
| actionView | GET | /v1/users/{id} | Yes | Owner/Admin | View user in tenant |
| actionCreate | POST | /v1/users | Yes | Owner/Admin | Create user (direct or invite) |
| actionUpdateRole | PUT | /v1/users/{id}/role | Yes | Owner | Update user role |

---

### CategoryController

**File:** `src/api/controllers/v1/CategoryController.php`
**Route prefix:** `v1/categories`
**Traits:** `CursorPaginationTrait`

| Action | Method | Route | Auth | Role | Description |
|---|---|---|---|---|---|
| actionIndex | GET | /v1/categories | Yes | All roles | List categories (paginated) |
| actionView | GET | /v1/categories/{id} | Yes | All roles | View single category |
| actionCreate | POST | /v1/categories | Yes | Owner/Admin | Create category |
| actionUpdate | PUT | /v1/categories/{id} | Yes | Owner/Admin | Update category |
| actionDelete | DELETE | /v1/categories/{id} | Yes | Owner/Admin | Delete category |

---

### AiKeyController

**File:** `src/api/controllers/v1/AiKeyController.php`
**Route prefix:** `v1/ai-keys`
**Traits:** `CursorPaginationTrait`

| Action | Method | Route | Auth | Role | Description |
|---|---|---|---|---|---|
| actionIndex | GET | /v1/ai-keys | Yes | Owner/Admin | List AI keys (paginated) |
| actionView | GET | /v1/ai-keys/{id} | Yes | Owner/Admin | View AI key (key masked) |
| actionCreate | POST | /v1/ai-keys | Yes | Owner/Admin | Create AI key |
| actionUpdate | PUT | /v1/ai-keys/{id} | Yes | Owner/Admin | Update AI key |
| actionDelete | DELETE | /v1/ai-keys/{id} | Yes | Owner/Admin | Delete AI key |

---

### LangfuseConfigController

**File:** `src/api/controllers/v1/LangfuseConfigController.php`
**Route prefix:** `v1/langfuse-config`

| Action | Method | Route | Auth | Role | Description |
|---|---|---|---|---|---|
| actionView | GET | /v1/langfuse-config | Yes | Owner/Admin | Get Langfuse config |
| actionUpdate | PUT | /v1/langfuse-config | Yes | Owner/Admin | Set/update Langfuse config |

---

### WriterController

**File:** `src/api/controllers/v1/WriterController.php`
**Route prefix:** `v1/writers`
**Traits:** `CursorPaginationTrait`

| Action | Method | Route | Auth | Role | Description |
|---|---|---|---|---|---|
| actionIndex | GET | /v1/writers | Yes | All roles | List writers (paginated) |
| actionView | GET | /v1/writers/{id} | Yes | All roles | View single writer |
| actionCreate | POST | /v1/writers | Yes | Owner/Admin | Create writer |
| actionUpdate | PUT | /v1/writers/{id} | Yes | Owner/Admin | Update writer |
| actionDelete | DELETE | /v1/writers/{id} | Yes | Owner/Admin | Delete writer |

---

### ReviserController

**File:** `src/api/controllers/v1/ReviserController.php`
**Route prefix:** `v1/revisers`
**Traits:** `CursorPaginationTrait`

| Action | Method | Route | Auth | Role | Description |
|---|---|---|---|---|---|
| actionIndex | GET | /v1/revisers | Yes | All roles | List revisers (paginated) |
| actionView | GET | /v1/revisers/{id} | Yes | All roles | View single reviser |
| actionCreate | POST | /v1/revisers | Yes | Owner/Admin | Create reviser |
| actionUpdate | PUT | /v1/revisers/{id} | Yes | Owner/Admin | Update reviser |
| actionDelete | DELETE | /v1/revisers/{id} | Yes | Owner/Admin | Delete reviser |

---

### PublishTargetController

**File:** `src/api/controllers/v1/PublishTargetController.php`
**Route prefix:** `v1/publish-targets`
**Traits:** `CursorPaginationTrait`

| Action | Method | Route | Auth | Role | Description |
|---|---|---|---|---|---|
| actionIndex | GET | /v1/publish-targets | Yes | Owner/Admin | List publish targets (paginated) |
| actionView | GET | /v1/publish-targets/{id} | Yes | Owner/Admin | View single target |
| actionCreate | POST | /v1/publish-targets | Yes | Owner/Admin | Create target |
| actionUpdate | PUT | /v1/publish-targets/{id} | Yes | Owner/Admin | Update target |
| actionDelete | DELETE | /v1/publish-targets/{id} | Yes | Owner/Admin | Delete target |

---

### UsageController

**File:** `src/api/controllers/v1/UsageController.php`
**Route prefix:** `v1/usage`
**Traits:** `CursorPaginationTrait`

| Action | Method | Route | Auth | Role | Description |
|---|---|---|---|---|---|
| actionIndex | GET | /v1/usage | Yes | Owner/Admin (tenant), PlatformAdmin (cross-tenant) | List monthly usage counters |

---

## Base Controller

**File:** `src/api/components/Controller.php`

Provides:
- JWT Bearer authentication via `JwtBearerAuth`
- JSON content negotiation
- Tenant context filter via `TenantFilter`
- Identity helpers: `getAuthenticatedUser()`, `getUserId()`, `getTenantId()`, `getUserRole()`
- Role enforcement: `requireRole()`, `requireAdmin()`, `requirePlatformAdmin()`
- Response builders: `buildSuccessResponse()`, `buildErrorResponse()`
- Request param helpers (PHPStan-safe): `getQueryParam()`, `setResponseStatus()`, `getBodyParams()`
- Request helpers: `getRawParameter()`, `getRawParameters()`

---

## Phase 3 Controllers

### BriefController

**File:** `src/api/controllers/v1/BriefController.php`
**Route prefix:** `v1/briefs`

| Action | Method | Route | Role | Description |
|---|---|---|---|---|
| actionIndex | GET | /v1/briefs | Editor+ | List briefs with cursor pagination |
| actionView | GET | /v1/briefs/{id} | Editor+ | View brief details |
| actionCreate | POST | /v1/briefs | Editor+ | Create a manual brief |
| actionAlsoaskedCreate | POST | /v1/briefs/alsoasked | Admin+ | Bulk import from AlsoAsked |
| actionKeywordResearchCreate | POST | /v1/briefs/keyword-research | Admin+ | Bulk import from keyword research |
| actionUpdate | PUT | /v1/briefs/{id} | Editor+ | Update draft brief only |
| actionDelete | DELETE | /v1/briefs/{id} | Admin+ | Delete draft brief only |
| actionApprove | POST | /v1/briefs/{id}/approve | Editor+ | Approve a draft brief |
| actionReject | POST | /v1/briefs/{id}/reject | Editor+ | Reject a draft brief |
| actionBatchApprove | POST | /v1/briefs/batch-approve | Editor+ | Bulk-approve briefs |

### ContentController

**File:** `src/api/controllers/v1/ContentController.php`
**Route prefix:** `v1/content`

| Action | Method | Route | Role | Description |
|---|---|---|---|---|
| actionIndex | GET | /v1/content | Editor+ | List content items with cursor pagination |
| actionView | GET | /v1/content/{id} | Editor+ | View content item details |
| actionGenerateFromBrief | POST | /v1/briefs/{id}/generate | Admin+ | Generate content from approved brief |
| actionSelectDraft | POST | /v1/content/{id}/select-draft | Editor+ | Select a draft for content |
| actionEdit | PUT | /v1/content/{id}/body | Editor+ | Edit selected draft body |
| actionApprove | POST | /v1/content/{id}/approve | Editor+ | Approve content |
| actionReject | POST | /v1/content/{id}/reject | Editor+ | Reject content (send back) |
| actionSchedule | POST | /v1/content/{id}/schedule | Admin+ | Schedule content for publishing |
| actionPublishNow | POST | /v1/content/{id}/publish | Admin+ | Queue content for immediate publish |
| actionCancel | POST | /v1/content/{id}/cancel | Admin+ | Archive content item |

### DraftController

**File:** `src/api/controllers/v1/DraftController.php`
**Route prefix:** `v1/content/{contentId}/drafts`

| Action | Method | Route | Role | Description |
|---|---|---|---|---|
| actionIndex | GET | /v1/content/{contentId}/drafts | Editor+ | List drafts (without body) |
| actionView | GET | /v1/content/{contentId}/drafts/{id} | Editor+ | View draft with body |

### RevisionController

**File:** `src/api/controllers/v1/RevisionController.php`
**Route prefix:** `v1/content/{contentId}`

| Action | Method | Route | Role | Description |
|---|---|---|---|---|
| actionTrigger | POST | /v1/content/{contentId}/revise | Admin+ | Trigger AI revision pass |
| actionHistory | GET | /v1/content/{contentId}/revisions | Editor+ | View revision history |
