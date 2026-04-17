# WiserContent API Documentation

**Base URL:** `/api/v1/`
**Content Type:** `application/json`
**Authentication:** JWT Bearer tokens (15-minute access tokens, 30-day rotating refresh tokens)

---

## Architecture

- **Framework:** Yii2 Advanced Template (PHP 8.2+)
- **Database:** MySQL 8+, single-database multi-tenant with row-level `tenant_id` scoping
- **Auth:** JWT access tokens (HS256, 15-min TTL) + rotating refresh tokens (30-day)
- **Pagination:** Cursor-based (`?cursor=&limit=`)
- **Queue:** Dragonfly via Yii2 Queue

## Response Envelope

### Success
```json
{
  "success": true,
  "data": { ... }
}
```

### Error
```json
{
  "success": false,
  "message": "Human-readable error message",
  "errors": { ... }
}
```

### Paginated List
```json
{
  "success": true,
  "data": {
    "items": [ ... ],
    "next_cursor": "base64-encoded-cursor-or-null"
  }
}
```

## Authentication Flow

1. `POST /v1/auth/login` with email/password to get access + refresh tokens
2. Use `Authorization: Bearer <access_token>` on all authenticated requests
3. When access token expires, `POST /v1/auth/refresh` with refresh_token to get new tokens
4. To switch active tenant: `POST /v1/auth/switch-tenant` with tenant_id

## Tenant Isolation

Every authenticated request is scoped to the active tenant from the JWT. Users can only see/modify data belonging to their active tenant. PlatformAdmins can access any tenant's data.

## Roles

**Platform-level:** PlatformAdmin (super-admin, manages tenants)

**Tenant-level (per membership):**
- Owner: Full tenant control
- Admin: Manage config and content
- Editor: Create/edit content, approve
- Viewer: Read-only

## Endpoint Groups

- `/auth`: Login, refresh, switch-tenant, me
- `/tenants`: CRUD (PlatformAdmin only)
- `/users`: Tenant-scoped user management
- `/categories`: Tenant CRUD
- `/writers`: Tenant CRUD
- `/revisers`: Tenant CRUD
- `/ai-keys`: Tenant AI provider key management
- `/langfuse-config`: Tenant Langfuse configuration
- `/publish-targets`: Tenant webhook targets
- `/usage`: Monthly usage counters
