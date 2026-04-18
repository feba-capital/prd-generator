# API Models Reference

## Confirmed Models

### Example

| Property | Type | Description |
|---|---|---|
| id | bigint | Primary key |
| name | text | Display name |

## Proposed Models

- None.

## Model Relationships

- `example.owner_id` -> `membership.id`

## RLS Policy Summary

### Policy `example_insert_self`
**Table:** `public.example`
**Operation:** `INSERT`
**Access summary:** `authenticated user can create example`
**WITH CHECK:** `owner_id = auth.uid()`
