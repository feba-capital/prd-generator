# API Models Reference

## Confirmed Models

### MemoryApproval

| Property | Type | Description |
|---|---|---|
| id | bigint | Primary key |
| memory_id | bigint | Memory reference |
| decision | text | approved or rejected |

## Proposed Models

- None.

## Model Relationships

- `memory_approval.memory_id` -> `memory.id`

## RLS Policy Summary

### Policy `memory_approvals_insert_by_driver_or_owner_or_copilot`
**Table:** `public.memory_approvals`
**Operation:** `INSERT`
**Access summary:** `driver, owner, or copilot can approve memory`
**WITH CHECK:** `public.has_any_role(auth.uid(), ARRAY['driver','owner','copilot'])`
