# API Endpoints Reference

# Confirmed Endpoints

### GET /api/v1/restock-requests

**Table:** `public.restock_request`
**Governing policy:** `restock_request_select_visible`
**Access summary:** `authenticated users can read open rows; requester or admin can read non-open rows`
**Field contract:** `id`, `status`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "status": "open"
      }
    ]
  }
}
```

# Proposed Endpoints

- None.
