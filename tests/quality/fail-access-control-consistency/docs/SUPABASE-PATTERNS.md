# Supabase Patterns

## RLS Policies

```sql
-- ACCESS: owner or copilot can approve memory
CREATE POLICY memory_approvals_insert_by_owner_or_copilot
  ON public.memory_approvals
  FOR INSERT TO authenticated
  WITH CHECK (public.has_any_role(auth.uid(), ARRAY['owner','copilot']));
```

## RLS Lint Checklist

- Non-admin update paths use a trigger or helper function to constrain mutable columns.
- State-transition policies include an explicit transition comment.
- Non-admin `WITH CHECK` predicates are stricter than their `USING` predicates.

## Strict Transition Example

- Not needed for this fixture.
