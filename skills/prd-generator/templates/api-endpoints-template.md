# API Endpoints Reference

All endpoints use the `/api/v{{VERSION}}/` prefix. Responses follow the standard envelope format in `api-docs.md`.

This file is split into two sections:

- `# Confirmed Endpoints` -> derived from explicit user flows and Fabio's confirmed decisions
- `# Proposed Endpoints` -> skill inference that still needs explicit promotion

Never move an endpoint from Proposed to Confirmed without Fabio's approval.

---

# Confirmed Endpoints

## Endpoint Contract Rules

Every endpoint entry MUST include:

- heading in the form `### METHOD /api/v{{VERSION}}/...`
- `Table`
- `Governing policy`
- `Access summary`
- `Field contract`
- request and/or response examples

Use `Governing policy: n/a (service-layer auth)` only when the endpoint is not backed by table RLS.

## Auth Endpoints

### POST /api/v{{VERSION}}/auth/login

Authenticate with email/password. Returns access and refresh tokens.

**Table:** `n/a (service-layer auth)`
**Governing policy:** `n/a (service-layer auth)`
**Access summary:** `public`
**Field contract:** `email`, `password`, `access_token`, `refresh_token`, `expires_in`, `id`, `created_at`

**Request:**
```json
{
  "email": "user@example.com",
  "password": "secret"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "token",
    "refresh_token": "refresh-token",
    "expires_in": 900,
    "user": {
      "id": 1,
      "email": "user@example.com",
      "created_at": "2026-04-17T10:00:00Z"
    }
  }
}
```

**Errors:**
- `400` -> Missing credentials
- `401` -> Invalid credentials

---

### POST /api/v{{VERSION}}/auth/refresh

Rotate the refresh token and return a new access token pair.

**Table:** `n/a (service-layer auth)`
**Governing policy:** `n/a (service-layer auth)`
**Access summary:** `public with valid refresh token`
**Field contract:** `refresh_token`, `access_token`, `expires_in`

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
    "expires_in": 900
  }
}
```

---

### GET /api/v{{VERSION}}/auth/me

Return the authenticated user profile.

**Table:** `public.user_profile`
**Governing policy:** `user_profile_select_self`
**Access summary:** `authenticated user can read own profile`
**Field contract:** `id`, `email`, `name`, `created_at`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "User Name",
    "created_at": "2026-04-17T10:00:00Z"
  }
}
```

---

## Resource Endpoint Pattern

Use this pattern for every domain endpoint:

### GET /api/v{{VERSION}}/{{CORE_ENTITIES|first|pluralize|downcase}}

List {{CORE_ENTITIES|first|pluralize}}.

**Table:** `public.{{CORE_ENTITIES|first|pluralize|downcase}}`
**Governing policy:** `{{CORE_ENTITIES|first|pluralize|downcase}}_select_visible`
**Access summary:** `authenticated users can read rows allowed by policy`
**Field contract:** `id`, `name`, `status`, `created_at`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "name": "Example",
        "status": "active",
        "created_at": "2026-04-17T10:00:00Z"
      }
    ],
    "next_cursor": null
  }
}
```

---

### POST /api/v{{VERSION}}/{{CORE_ENTITIES|first|pluralize|downcase}}

Create a new {{CORE_ENTITIES|first|downcase}}.

**Table:** `public.{{CORE_ENTITIES|first|pluralize|downcase}}`
**Governing policy:** `{{CORE_ENTITIES|first|pluralize|downcase}}_insert_self`
**Access summary:** `authenticated users can create rows allowed by policy`
**Field contract:** `name`, `status`, `id`, `created_at`

**Request:**
```json
{
  "name": "Example",
  "status": "active"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Example",
    "status": "active",
    "created_at": "2026-04-17T10:00:00Z"
  }
}
```

---

### POST /api/v{{VERSION}}/{{CORE_ENTITIES|first|pluralize|downcase}}/{id}/resolve

Use action-style endpoints only when the flow is explicit in the PRD and the action cannot be expressed as a simple row update.

**Table:** `public.{{CORE_ENTITIES|first|pluralize|downcase}}`
**Governing policy:** `{{CORE_ENTITIES|first|pluralize|downcase}}_resolve`
**Access summary:** `role or owner rule exactly as written in api-models.md`
**Field contract:** `id`, `status`, `resolved_at`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "status": "resolved",
    "resolved_at": "2026-04-17T10:05:00Z"
  }
}
```

---

# Proposed Endpoints

Skill inference based on MVP scope. Awaiting Fabio's approval. Do not implement these until promoted to Confirmed.

### POST /api/v{{VERSION}}/example

**Reason for Proposal:** derived from a likely workflow gap, not yet confirmed
**Table:** `public.example`
**Governing policy:** `example_insert`
**Access summary:** `role or actor rule to be confirmed`
**Field contract:** `id`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1
  }
}
```
