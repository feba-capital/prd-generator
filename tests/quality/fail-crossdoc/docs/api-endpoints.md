# API Endpoints Reference

# Confirmed Endpoints

### GET /api/v1/restock-requests

**Table:** `public.restock_request`
**Governing policy:** `restock_request_select_visible`
**Access summary:** `requester only`
**Field contract:** `id`, `snack_id`, `status`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "snack_id": 9,
        "status": "open"
      }
    ]
  }
}
```

# Proposed Endpoints

- None.
