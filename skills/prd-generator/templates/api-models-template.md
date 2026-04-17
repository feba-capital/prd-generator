# API Models Reference

All IDs are stack-appropriate integers unless Fabio explicitly asks for another format. Timestamps should match the stack conventions documented in the chosen preset.

---

## Confirmed Models

List only Fabio-approved entities here. Every property that appears in `api-endpoints.md` request/response bodies must exist in one of these tables.

### {{CORE_ENTITIES|first|titleize}}

**Table:** `public.{{CORE_ENTITIES|first|pluralize|downcase}}`
**Owner:** `{{CORE_ENTITIES|first|titleize}}` module

| Property | Type | Description |
|---|---|---|
| id | bigint | Primary key |
| name | text | Human-readable label |
| status | text | Current state |
| created_at | timestamptz | Creation timestamp |
| updated_at | timestamptz | Update timestamp |

**Constraints:**
- Add only constraints that are explicit in the PRD or endpoint contract

**Methods / helpers:**
- Keep this short and practical

---

### {{CORE_ENTITIES|second|titleize}}

**Table:** `public.{{CORE_ENTITIES|second|pluralize|downcase}}`
**Owner:** `{{CORE_ENTITIES|second|titleize}}` module

| Property | Type | Description |
|---|---|---|
| id | bigint | Primary key |
| created_at | timestamptz | Creation timestamp |
| updated_at | timestamptz | Update timestamp |

---

## Proposed Models

Skill inference based on MVP scope. Awaiting Fabio's approval. Do not implement until promoted.

---

## Model Relationships

- `{{CORE_ENTITIES|first|pluralize|downcase}}` -> related entities and ownership boundaries
- `{{CORE_ENTITIES|second|pluralize|downcase}}` -> related entities and ownership boundaries

---

## RLS Policy Summary

Mirror the exact policy contract from `SUPABASE-PATTERNS.md`. Do not paraphrase the predicates.

### Policy `{{CORE_ENTITIES|first|pluralize|downcase}}_select_visible`
**Table:** `public.{{CORE_ENTITIES|first|pluralize|downcase}}`
**Operation:** `SELECT`
**Access summary:** `write the same access sentence used by the matching endpoint`
**USING:** `copy the exact USING predicate from SUPABASE-PATTERNS.md`

### Policy `{{CORE_ENTITIES|first|pluralize|downcase}}_insert_self`
**Table:** `public.{{CORE_ENTITIES|first|pluralize|downcase}}`
**Operation:** `INSERT`
**Access summary:** `write the same access sentence used by the matching endpoint`
**WITH CHECK:** `copy the exact WITH CHECK predicate from SUPABASE-PATTERNS.md`

### Policy `{{CORE_ENTITIES|first|pluralize|downcase}}_cancel_self`
**Table:** `public.{{CORE_ENTITIES|first|pluralize|downcase}}`
**Operation:** `UPDATE`
**Access summary:** `write the same access sentence used by the matching endpoint`
**USING:** `copy the exact USING predicate from SUPABASE-PATTERNS.md`
**WITH CHECK:** `copy the exact WITH CHECK predicate from SUPABASE-PATTERNS.md`
**Enforced by:** `trigger: exact_guard_name` or `function: exact_helper_name`

---

## Notes

- Keep `Access summary` strings identical between this file and `api-endpoints.md`
- Only summarize policies that the generated package actually relies on
- If a read or mutation path is not backed by a policy here, it is not implementation-ready
