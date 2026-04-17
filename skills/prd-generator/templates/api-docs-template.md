# {{PROJECT_NAME}} API Documentation

**Base URL:** `/api/v{{VERSION}}/`
**Content Type:** `application/json`
**Authentication:** {{AUTH_METHOD}}

---

## Architecture

- **Framework:** {{STACK_DESCRIPTION}}
- **Database:** {{STACK_DESCRIPTION|extract:database}}
{{#MULTITENANT_YES_NO}}
- **Multi-tenant:** Single database, row-level `tenant_id` scoping
{{/MULTITENANT_YES_NO}}
- **Pagination:** Cursor-based (`?cursor=&limit=`)

---

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

---

## Authentication Flow

### Step 1: Login
`POST /api/v{{VERSION}}/auth/login` with email/password to get access + refresh tokens.

### Step 2: Authenticated Requests
Use `Authorization: Bearer <access_token>` on all authenticated endpoints.

### Step 3: Token Refresh
When access token expires, `POST /api/v{{VERSION}}/auth/refresh` with refresh_token to get new tokens.

{{#MULTITENANT_YES_NO}}
### Step 4: Tenant Switching (multi-tenant only)
`POST /api/v{{VERSION}}/auth/switch-tenant` with target `tenant_id` to switch active tenant context.
{{/MULTITENANT_YES_NO}}

---

## Token Details

- **Access tokens:** JWT, short-lived (15 minutes)
- **Refresh tokens:** Rotating, long-lived (30 days)
- All tokens include authenticated user context and active tenant scope

---

{{#MULTITENANT_YES_NO}}
## Tenant Isolation

Every authenticated request is scoped to the active tenant from the JWT. Users can only see/modify data belonging to their active tenant.

**PlatformAdmin** role can access any tenant's data and is the only user type that can manage global configuration.

---

## Roles

**Platform-level:** PlatformAdmin (super-admin, manages tenants)

**Tenant-level:**
- Owner: Full control
- Admin: Manage resources
- Editor: Create/edit/approve content
- Viewer: Read-only

---
{{/MULTITENANT_YES_NO}}

## Endpoint Groups (v{{VERSION}})

{{#INTEGRATIONS_IN_SCOPE}}
- `{{. }}` -> endpoints for this resource
{{/INTEGRATIONS_IN_SCOPE}}

---

## Error Codes

| Code | Meaning | Recovery |
|---|---|---|
| 400 | Bad Request | Check request format and required fields |
| 401 | Unauthorized | Login required or token expired |
| 403 | Forbidden | Insufficient permissions for this action |
| 404 | Not Found | Resource doesn't exist or you don't have access |
| 409 | Conflict | Resource already exists or state conflict |
| 422 | Validation Error | Field validation failed, see `errors` detail |
| 500 | Server Error | Unexpected error, contact support with trace ID |

---

## Rate Limiting

{{#VERSION}}Version {{VERSION}}:{{/VERSION}} No rate limiting.

(Subject to change in future versions for large-scale deployments.)

---

## Best Practices

- Use the `next_cursor` from paginated responses to fetch subsequent pages
- Always handle token refresh transparently on 401 responses
- Retry failed requests with exponential backoff (non-2xx responses)
- Log response `X-Trace-Id` header for debugging

---

*For detailed endpoint specs, see [api-endpoints.md](api-endpoints.md).*
*For data models, see [api-models.md](api-models.md).*
