# API Endpoints Reference

# Confirmed Endpoints

This snapshot only includes confirmed endpoints derived from the current WiserContent PRD and companion docs.

All endpoints use the `/api/v1/` prefix. Responses follow the standard envelope format.

---

## Auth Endpoints

### POST /v1/auth/login

Authenticate with email/password. Returns JWT tokens.

**Auth Required:** No

**Request:**
```json
{
  "email": "user@example.com",
  "password": "secret",
  "tenant_id": 1,
  "mfa_code": "123456"
}
```
- `tenant_id`: optional for single-tenant users, required for multi-tenant
- `mfa_code`: required when tenant enforces MFA and user has it enabled

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiJ9...",
    "refresh_token": "random-token-string",
    "expires_in": 900,
    "user": {
      "id": 1,
      "email": "user@example.com",
      "is_platform_admin": false,
      "mfa_enabled": false,
      "created_at": 1713024000
    },
    "tenant": {
      "id": 1,
      "name": "Test Company",
      "slug": "test-company",
      "timezone": "UTC",
      "mfa_required": false
    },
    "role": "editor"
  }
}
```

**Errors:**
- `400`: Missing email/password, or multi-tenant user without tenant_id
- `401`: Invalid credentials, inactive user
- `403`: User not member of requested tenant, MFA required

---

### POST /v1/auth/refresh

Rotate refresh token and get new access + refresh tokens.

**Auth Required:** No

**Request:**
```json
{
  "refresh_token": "old-refresh-token"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "new-access-token",
    "refresh_token": "new-refresh-token",
    "expires_in": 900,
    "user": { ... },
    "tenant": { ... },
    "role": "editor"
  }
}
```

**Errors:**
- `400`: Missing refresh_token
- `401`: Invalid, expired, or revoked refresh token

---

### POST /v1/auth/switch-tenant

Switch active tenant context. Returns new access token.

**Auth Required:** Yes

**Request:**
```json
{
  "tenant_id": 2
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "new-access-token",
    "expires_in": 900,
    "tenant": {
      "id": 2,
      "name": "Second Company",
      "slug": "second-company",
      "timezone": "America/New_York",
      "mfa_required": false
    },
    "role": "viewer"
  }
}
```

**Errors:**
- `400`: Missing tenant_id
- `401`: Not authenticated
- `403`: User not member of target tenant

---

### GET /v1/auth/me

Get current user profile, active tenant, and all tenant memberships.

**Auth Required:** Yes

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "is_platform_admin": false,
      "mfa_enabled": false,
      "created_at": 1713024000
    },
    "active_tenant": {
      "id": 1,
      "name": "Test Company",
      "slug": "test-company",
      "timezone": "UTC",
      "mfa_required": false
    },
    "role": "owner",
    "tenants": [
      {
        "tenant_id": 1,
        "name": "Test Company",
        "slug": "test-company",
        "role": "owner"
      },
      {
        "tenant_id": 2,
        "name": "Second Company",
        "slug": "second-company",
        "role": "editor"
      }
    ]
  }
}
```

**Errors:**
- `401`: Not authenticated

---

## Tenant Endpoints (PlatformAdmin only)

### GET /v1/tenants

List all tenants with cursor pagination.

**Auth Required:** Yes (PlatformAdmin)

**Query params:** `cursor`, `limit` (default 20, max 100), `status`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "name": "Test Company",
        "slug": "test-company",
        "timezone": "UTC",
        "status": "active",
        "mfa_required": false,
        "created_at": 1713024000,
        "updated_at": 1713024000
      }
    ],
    "next_cursor": "MQ=="
  }
}
```

---

### GET /v1/tenants/{id}

View a single tenant.

**Auth Required:** Yes (PlatformAdmin)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "tenant": {
      "id": 1,
      "name": "Test Company",
      "slug": "test-company",
      "timezone": "UTC",
      "status": "active",
      "mfa_required": false,
      "created_at": 1713024000,
      "updated_at": 1713024000
    }
  }
}
```

---

### POST /v1/tenants

Create a new tenant.

**Auth Required:** Yes (PlatformAdmin)

**Request:**
```json
{
  "name": "New Company",
  "slug": "new-company",
  "timezone": "America/New_York",
  "mfa_required": false
}
```

**Response (201):** Same as GET /v1/tenants/{id}

---

### PUT /v1/tenants/{id}

Update an existing tenant.

**Auth Required:** Yes (PlatformAdmin)

**Request:** Partial update: only include fields to change.
```json
{
  "name": "Updated Name",
  "status": "inactive"
}
```

**Response (200):** Same as GET /v1/tenants/{id}

---

## User Endpoints (Tenant-scoped)

### GET /v1/users

List users in the current tenant.

**Auth Required:** Yes (Owner/Admin)

**Query params:** `cursor`, `limit`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "email": "user@example.com",
        "status": "active",
        "is_platform_admin": false,
        "mfa_enabled": false,
        "role": "editor",
        "created_at": 1713024000,
        "updated_at": 1713024000
      }
    ],
    "next_cursor": null
  }
}
```

---

### GET /v1/users/{id}

View a user within the current tenant.

**Auth Required:** Yes (Owner/Admin)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "status": "active",
      "is_platform_admin": false,
      "mfa_enabled": false,
      "role": "editor",
      "created_at": 1713024000,
      "updated_at": 1713024000
    }
  }
}
```

---

### POST /v1/users

Create a user directly (with password) or invite via email.

**Auth Required:** Yes (Owner/Admin)

**Request (direct creation):**
```json
{
  "email": "new@example.com",
  "password": "secure-password",
  "role": "editor"
}
```

**Response (201): direct:** Same as GET /v1/users/{id}

**Request (invitation):**
```json
{
  "email": "invite@example.com",
  "role": "viewer"
}
```

**Response (201): invitation:**
```json
{
  "success": true,
  "data": {
    "invitation": {
      "id": 1,
      "email": "invite@example.com",
      "role": "viewer",
      "expires_at": 1713628800,
      "token": "random-invitation-token"
    }
  }
}
```

**Errors:**
- `409`: User already belongs to this tenant

---

### PUT /v1/users/{id}/role

Update a user's role within the current tenant.

**Auth Required:** Yes (Owner only)

**Request:**
```json
{
  "role": "admin"
}
```

**Response (200):** Same as GET /v1/users/{id}

---

## Category Endpoints (Tenant-scoped)

### GET /v1/categories

List categories. All roles can read.

**Auth Required:** Yes (All roles)

**Query params:** `cursor`, `limit`, `status`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "tenant_id": 1,
        "name": "Technology",
        "slug": "technology",
        "description": "All things tech",
        "status": "active",
        "created_at": 1713024000,
        "updated_at": 1713024000
      }
    ],
    "next_cursor": null
  }
}
```

---

### GET /v1/categories/{id}

View a single category.

**Auth Required:** Yes (All roles)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "category": { ... }
  }
}
```

---

### POST /v1/categories

Create a new category.

**Auth Required:** Yes (Owner/Admin)

**Request:**
```json
{
  "name": "Technology",
  "slug": "technology",
  "description": "All things tech"
}
```

**Response (201):** Same as GET /v1/categories/{id}

**Errors:**
- `422`: Validation failed (e.g., duplicate slug per tenant)

---

### PUT /v1/categories/{id}

Update a category.

**Auth Required:** Yes (Owner/Admin)

**Request:** Partial update.
```json
{
  "name": "Updated Name",
  "status": "inactive"
}
```

**Response (200):** Same as GET /v1/categories/{id}

---

### DELETE /v1/categories/{id}

Delete a category. Blocked if referenced by briefs or content items.

**Auth Required:** Yes (Owner/Admin)

**Response (200):**
```json
{
  "success": true,
  "data": { "deleted": true }
}
```

**Errors:**
- `404`: Category not found
- `409`: Category is referenced (future: when briefs/content_items exist)

---

## AI Key Endpoints (Tenant-scoped)

### GET /v1/ai-keys

List AI provider keys. Actual keys are never exposed.

**Auth Required:** Yes (Owner/Admin)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "tenant_id": 1,
        "ai_provider_id": 1,
        "provider": {
          "id": 1,
          "name": "Anthropic",
          "slug": "anthropic"
        },
        "model_default": "claude-3-opus",
        "has_key": true,
        "created_at": 1713024000,
        "updated_at": 1713024000
      }
    ],
    "next_cursor": null
  }
}
```

---

### POST /v1/ai-keys

Create an AI provider key.

**Auth Required:** Yes (Owner/Admin)

**Request:**
```json
{
  "ai_provider_id": 1,
  "api_key": "sk-actual-api-key",
  "model_default": "claude-3-opus"
}
```

**Response (201):** Same format as list item (key is NOT included in response)

---

### PUT /v1/ai-keys/{id}

Update an AI provider key.

**Auth Required:** Yes (Owner/Admin)

**Request:**
```json
{
  "api_key": "sk-new-api-key",
  "model_default": "claude-3.5-sonnet"
}
```

---

### DELETE /v1/ai-keys/{id}

Delete an AI provider key.

**Auth Required:** Yes (Owner/Admin)

**Response (200):** `{ "success": true, "data": { "deleted": true } }`

---

## Langfuse Config Endpoints (Tenant-scoped, single record)

### GET /v1/langfuse-config

Get the current tenant's Langfuse configuration. Returns `null` if not configured.

**Auth Required:** Yes (Owner/Admin)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "langfuse_config": {
      "id": 1,
      "tenant_id": 1,
      "host": "https://langfuse.example.com",
      "public_key": "pk-lf-123",
      "project_name": "my-project",
      "has_secret_key": true,
      "created_at": 1713024000,
      "updated_at": 1713024000
    }
  }
}
```

---

### PUT /v1/langfuse-config

Create or update Langfuse configuration.

**Auth Required:** Yes (Owner/Admin)

**Request:**
```json
{
  "host": "https://langfuse.example.com",
  "public_key": "pk-lf-123",
  "secret_key": "sk-lf-secret",
  "project_name": "my-project"
}
```

**Response (201 if new, 200 if update):** Same as GET /v1/langfuse-config

---

## Writer Endpoints (Tenant-scoped)

### GET /v1/writers

List writers. All roles can read.

**Auth Required:** Yes (All roles)

**Query params:** `cursor`, `limit`, `status`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "tenant_id": 1,
        "name": "Tech Writer",
        "ai_provider_id": 1,
        "provider": { "id": 1, "name": "Anthropic", "slug": "anthropic" },
        "model": "claude-3-opus",
        "langfuse_prompt_label": "tech-writer-v1",
        "personality_metadata": { "tone": "professional" },
        "category_assignments": [1, 2, 3],
        "content_type_assignments": ["how_to", "explainer"],
        "is_default": true,
        "status": "active",
        "created_at": 1713024000,
        "updated_at": 1713024000
      }
    ],
    "next_cursor": null
  }
}
```

---

### POST /v1/writers

Create a new writer.

**Auth Required:** Yes (Owner/Admin)

**Request:**
```json
{
  "name": "Tech Writer",
  "ai_provider_id": 1,
  "model": "claude-3-opus",
  "langfuse_prompt_label": "tech-writer-v1",
  "personality_metadata": { "tone": "professional" },
  "category_assignments": [1, 2],
  "content_type_assignments": ["how_to"],
  "is_default": true
}
```

**Response (201):** Same as single writer object

---

### PUT /v1/writers/{id}

Update a writer. Partial update.

**Auth Required:** Yes (Owner/Admin)

---

### DELETE /v1/writers/{id}

Delete a writer.

**Auth Required:** Yes (Owner/Admin)

**Response (200):** `{ "success": true, "data": { "deleted": true } }`

---

## Reviser Endpoints (Tenant-scoped)

### GET /v1/revisers

List revisers. All roles can read.

**Auth Required:** Yes (All roles)

**Query params:** `cursor`, `limit`, `status`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "tenant_id": 1,
        "name": "Grammar Checker",
        "ai_provider_id": 1,
        "provider": { "id": 1, "name": "Anthropic", "slug": "anthropic" },
        "model": "gpt-4",
        "langfuse_prompt_label": "grammar-v1",
        "metadata": { "focus": "grammar" },
        "is_default": true,
        "status": "active",
        "created_at": 1713024000,
        "updated_at": 1713024000
      }
    ],
    "next_cursor": null
  }
}
```

---

### POST /v1/revisers

Create a new reviser.

**Auth Required:** Yes (Owner/Admin)

**Request:**
```json
{
  "name": "Grammar Checker",
  "ai_provider_id": 1,
  "model": "gpt-4",
  "langfuse_prompt_label": "grammar-v1",
  "metadata": { "focus": "grammar" },
  "is_default": true
}
```

**Response (201):** Same as single reviser object

---

### PUT /v1/revisers/{id}

Update a reviser. Partial update.

**Auth Required:** Yes (Owner/Admin)

---

### DELETE /v1/revisers/{id}

Delete a reviser.

**Auth Required:** Yes (Owner/Admin)

**Response (200):** `{ "success": true, "data": { "deleted": true } }`

---

## Publish Target Endpoints (Tenant-scoped)

### GET /v1/publish-targets

List publish targets.

**Auth Required:** Yes (Owner/Admin)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "tenant_id": 1,
        "name": "WordPress Blog",
        "webhook_url": "https://blog.example.com/webhook",
        "payload_template": "{\"title\": \"{{title}}\"}",
        "has_auth_header": true,
        "active": true,
        "created_at": 1713024000,
        "updated_at": 1713024000
      }
    ],
    "next_cursor": null
  }
}
```

---

### POST /v1/publish-targets

Create a publish target. Auth header is encrypted, never exposed in responses.

**Auth Required:** Yes (Owner/Admin)

**Request:**
```json
{
  "name": "WordPress Blog",
  "webhook_url": "https://blog.example.com/webhook",
  "payload_template": "{\"title\": \"{{title}}\"}",
  "auth_header": "Bearer secret-token",
  "active": true
}
```

**Response (201):** Same as list item (auth_header NOT included)

---

### PUT /v1/publish-targets/{id}

Update a publish target. Partial update.

**Auth Required:** Yes (Owner/Admin)

---

### DELETE /v1/publish-targets/{id}

Delete a publish target.

**Auth Required:** Yes (Owner/Admin)

**Response (200):** `{ "success": true, "data": { "deleted": true } }`

---

## Usage Endpoints

### GET /v1/usage

List monthly usage counters for the current tenant. PlatformAdmin can filter by `tenant_id` for cross-tenant viewing.

**Auth Required:** Yes (Owner/Admin for tenant, PlatformAdmin for cross-tenant)

**Query params:** `cursor`, `limit`, `year_month`, `tenant_id` (PlatformAdmin only)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "tenant_id": 1,
        "year_month": "2026-04",
        "articles_generated": 15,
        "articles_published": 10,
        "created_at": 1713024000,
        "updated_at": 1713024000
      }
    ],
    "next_cursor": null
  }
}
```

---

## Brief Endpoints

### GET /v1/briefs

List briefs with cursor pagination.

**Auth Required:** Yes (Editor+)

**Query Params:** `status`, `category_id`, `content_type`, `cursor`, `limit`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "tenant_id": 1,
        "category_id": 5,
        "title": "How to Optimize Landing Pages",
        "content_type": "how_to",
        "keywords": ["landing pages", "optimization", "CRO"],
        "source": "manual",
        "status": "draft",
        "approved_by": null,
        "approved_at": null,
        "brief_approval_batch_id": null,
        "created_at": 1713024000,
        "updated_at": 1713024000
      }
    ],
    "next_cursor": "eyJpZCI6MX0="
  }
}
```

### GET /v1/briefs/{id}

**Auth Required:** Yes (Editor+)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "brief": {
      "id": 1, "tenant_id": 1, "category_id": 5,
      "title": "How to Optimize Landing Pages",
      "content_type": "how_to", "keywords": ["landing pages"],
      "source": "manual", "status": "draft",
      "approved_by": null, "approved_at": null,
      "brief_approval_batch_id": null,
      "created_at": 1713024000, "updated_at": 1713024000
    }
  }
}
```

### POST /v1/briefs

**Auth Required:** Yes (Editor+)

**Request:**
```json
{
  "title": "How to Optimize Landing Pages",
  "content_type": "how_to",
  "category_id": 5,
  "keywords": ["landing pages", "optimization"]
}
```

**Response (201):** `{ "success": true, "data": { "brief": { ... } } }`

### POST /v1/briefs/alsoasked

Bulk import from AlsoAsked. **Auth Required:** Yes (Admin+)

**Request:**
```json
{
  "category_id": 5,
  "items": [
    { "title": "What is CRO?", "content_type": "explainer", "keywords": ["CRO"] }
  ]
}
```

**Response (201):** `{ "success": true, "data": { "created_count": 1, "briefs": [...] } }`

### POST /v1/briefs/keyword-research

Bulk import from keyword research. Same format as `/v1/briefs/alsoasked`.

**Auth Required:** Yes (Admin+)

### PUT /v1/briefs/{id}

Update draft brief only. **Auth Required:** Yes (Editor+)

**Request:** `{ "title": "...", "content_type": "...", "category_id": 10, "keywords": [...] }`

**Response (200):** `{ "success": true, "data": { "brief": { ... } } }`

### DELETE /v1/briefs/{id}

Delete draft brief only. **Auth Required:** Yes (Admin+)

**Response (200):** `{ "success": true, "data": { "deleted": true } }`

### POST /v1/briefs/{id}/approve

**Auth Required:** Yes (Editor+)

**Response (200):** `{ "success": true, "data": { "brief": { "status": "approved", ... } } }`

### POST /v1/briefs/{id}/reject

**Auth Required:** Yes (Editor+)

**Response (200):** `{ "success": true, "data": { "brief": { "status": "rejected", ... } } }`

### POST /v1/briefs/batch-approve

**Auth Required:** Yes (Editor+)

**Request:** `{ "brief_ids": [1, 2, 3], "name": "May batch", "month": "2026-05" }`

**Response (200):** `{ "success": true, "data": { "batch_id": 1, "approved_count": 3 } }`

---

## Content Endpoints

### GET /v1/content

List content items. **Auth Required:** Yes (Editor+)

**Query Params:** `status`, `brief_id`, `cursor`, `limit`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1, "tenant_id": 1, "brief_id": 5,
        "parent_content_id": null, "status": "written",
        "selected_draft_id": 2, "approved_by": null,
        "approved_at": null, "scheduled_at_utc": null,
        "published_at_utc": null, "publish_target_id": null,
        "created_at": 1713024000, "updated_at": 1713024000
      }
    ],
    "next_cursor": null
  }
}
```

### GET /v1/content/{id}

**Auth Required:** Yes (Editor+)

**Response (200):** `{ "success": true, "data": { "content": { ... } } }`

### POST /v1/briefs/{id}/generate

Generate content from approved brief. **Auth Required:** Yes (Admin+)

**Response (202):** `{ "success": true, "data": { "content": { "status": "generating" }, "writers_assigned": 2 } }`

### POST /v1/content/{id}/select-draft

**Auth Required:** Yes (Editor+)

**Request:** `{ "draft_id": 3 }`

**Response (200):** `{ "success": true, "data": { "content": { "selected_draft_id": 3, ... } } }`

### PUT /v1/content/{id}/body

Edit selected draft body. **Auth Required:** Yes (Editor+)

**Request:** `{ "body": "<h1>Updated</h1><p>New body...</p>" }`

**Response (200):** `{ "success": true, "data": { "content": { ... } } }`

### POST /v1/content/{id}/approve

**Auth Required:** Yes (Editor+). Optional: `{ "draft_id": 3 }`

**Response (200):** `{ "success": true, "data": { "content": { "status": "approved", ... } } }`

### POST /v1/content/{id}/reject

**Auth Required:** Yes (Editor+)

**Request:** `{ "comment": "Needs more examples", "target_stage": "written" }`

**Response (200):** `{ "success": true, "data": { "content": { "status": "written", ... } } }`

### POST /v1/content/{id}/schedule

**Auth Required:** Yes (Admin+)

**Request:** `{ "scheduled_at": 1713110400, "publish_target_id": 2 }`

**Response (200):** `{ "success": true, "data": { "content": { "status": "scheduled", ... } } }`

### POST /v1/content/{id}/publish

Queue for immediate publish. **Auth Required:** Yes (Admin+)

**Request (if no target set):** `{ "publish_target_id": 2 }`

**Response (202):** `{ "success": true, "data": { "content": { ... } } }`

### POST /v1/content/{id}/cancel

Archive content. **Auth Required:** Yes (Admin+)

**Response (200):** `{ "success": true, "data": { "content": { "status": "archived", ... } } }`

---

## Draft Endpoints

### GET /v1/content/{contentId}/drafts

List drafts (without body). **Auth Required:** Yes (Editor+)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "drafts": [
      { "id": 1, "content_item_id": 5, "writer_id": 3, "version": 1, "status": "completed", "metadata": {}, "created_at": 1713024000, "updated_at": 1713024000 }
    ]
  }
}
```

### GET /v1/content/{contentId}/drafts/{id}

View draft with body. **Auth Required:** Yes (Editor+)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "draft": {
      "id": 1, "content_item_id": 5, "writer_id": 3, "version": 1,
      "status": "completed", "body": "<h1>Title</h1><p>Content...</p>",
      "metadata": {}, "created_at": 1713024000, "updated_at": 1713024000
    }
  }
}
```

---

## Revision Endpoints

### POST /v1/content/{contentId}/revise

Trigger AI revision. **Auth Required:** Yes (Admin+)

**Request:** `{ "reviser_id": 2 }`

**Response (202):** `{ "success": true, "data": { "content": { ... } } }`

### GET /v1/content/{contentId}/revisions

# Proposed Endpoints

No proposed endpoints are tracked in this frozen snapshot. Add future endpoint ideas here before promoting them to confirmed status.

View revision history. **Auth Required:** Yes (Editor+)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "revisions": [
      { "id": 1, "content_item_id": 5, "reviser_id": 2, "from_draft_id": 1, "to_draft_id": 3, "notes": null, "langfuse_trace_id": "trace-abc123", "created_at": 1713024000, "updated_at": 1713024000 }
    ]
  }
}
```
