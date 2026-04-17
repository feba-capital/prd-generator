# API Endpoints Reference

# Confirmed Endpoints

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
