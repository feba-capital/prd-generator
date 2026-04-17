# API Models Reference

## Confirmed Models

### RestockRequest

| Property | Type | Description |
|---|---|---|
| id | bigint | Primary key |
| requested_by_user_id | uuid | Request author |
| status | text | open or cancelled |
| cancelled_at | timestamptz | Cancellation timestamp |
| note | text | Optional note |

## Proposed Models

- None.

## Model Relationships

- `restock_request.id` -> `restock_request.id`

## RLS Policy Summary

### Policy `restock_request_cancel_self`
**Table:** `public.restock_request`
**Operation:** `UPDATE`
**Access summary:** `requester can transition own open row to cancelled`
**USING:** `requested_by_user_id = auth.uid() AND status = 'open'`
**WITH CHECK:** `requested_by_user_id = auth.uid() AND status IN ('open', 'cancelled')`
