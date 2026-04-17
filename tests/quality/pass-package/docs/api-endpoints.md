# API Endpoints Reference

# Confirmed Endpoints

### GET /api/v1/restock-requests

**Table:** `public.restock_request`
**Governing policy:** `restock_request_select_visible`
**Access summary:** `authenticated users can read open rows; requester or admin can read non-open rows`
**Field contract:** `id`, `snack_id`, `requested_by_user_id`, `status`, `note`, `created_at`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "snack_id": 9,
        "requested_by_user_id": "user_1",
        "status": "open",
        "note": "Please restock",
        "created_at": "2026-04-17T10:00:00Z"
      }
    ]
  }
}
```

### POST /api/v1/restock-requests

**Table:** `public.restock_request`
**Governing policy:** `restock_request_insert_self`
**Access summary:** `authenticated users can create their own request rows`
**Field contract:** `snack_id`, `note`, `id`, `requested_by_user_id`, `status`, `created_at`

**Request:**
```json
{
  "snack_id": 9,
  "note": "Please restock"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "snack_id": 9,
    "requested_by_user_id": "user_1",
    "status": "open",
    "note": "Please restock",
    "created_at": "2026-04-17T10:00:00Z"
  }
}
```

### POST /api/v1/restock-requests/{id}/cancel

**Table:** `public.restock_request`
**Governing policy:** `restock_request_cancel_self`
**Access summary:** `requester can transition own open row to cancelled`
**Field contract:** `id`, `status`, `cancelled_at`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "status": "cancelled",
    "cancelled_at": "2026-04-17T10:05:00Z"
  }
}
```

# Proposed Endpoints

- None.
