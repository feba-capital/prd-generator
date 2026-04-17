# API Models Reference

## Confirmed Models

### Snack

| Property | Type | Description |
|---|---|---|
| id | bigint | Primary key |
| name | text | Snack label |
| current_stock | integer | Current units |
| threshold | integer | Low-stock threshold |

### RestockRequest

| Property | Type | Description |
|---|---|---|
| id | bigint | Primary key |
| snack_id | bigint | Snack reference |
| requested_by_user_id | uuid | Request author |
| status | text | open or cancelled |
| note | text | Optional requester note |
| created_at | timestamptz | Creation timestamp |
| cancelled_at | timestamptz | Cancellation timestamp |

## Proposed Models

- None.

## Model Relationships

- `restock_request.snack_id` -> `snack.id`

## RLS Policy Summary

### Policy `restock_request_select_visible`
**Table:** `public.restock_request`
**Operation:** `SELECT`
**Access summary:** `authenticated users can read open rows; requester or admin can read non-open rows`
**USING:** `status = 'open' OR requested_by_user_id = auth.uid() OR public.is_admin(auth.uid())`

### Policy `restock_request_insert_self`
**Table:** `public.restock_request`
**Operation:** `INSERT`
**Access summary:** `authenticated users can create their own request rows`
**WITH CHECK:** `requested_by_user_id = auth.uid()`

### Policy `restock_request_cancel_self`
**Table:** `public.restock_request`
**Operation:** `UPDATE`
**Access summary:** `requester can transition own open row to cancelled`
**USING:** `requested_by_user_id = auth.uid() AND status = 'open'`
**WITH CHECK:** `requested_by_user_id = auth.uid() AND status = 'cancelled'`
**Enforced by:** `trigger: restock_request_cancel_self_guard`
