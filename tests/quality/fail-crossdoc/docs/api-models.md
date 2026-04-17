# API Models Reference

## Confirmed Models

### RestockRequest

| Property | Type | Description |
|---|---|---|
| id | bigint | Primary key |
| snack_id | bigint | Snack reference |
| status | text | open or cancelled |

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
