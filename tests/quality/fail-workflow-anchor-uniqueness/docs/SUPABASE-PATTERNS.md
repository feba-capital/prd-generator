# Supabase Patterns

## RLS Policies

```sql
-- ACCESS: authenticated user can create example
CREATE POLICY example_insert_self
  ON public.example
  FOR INSERT TO authenticated
  WITH CHECK (owner_id = auth.uid());
```

## RLS Lint Checklist

- Non-admin update paths use a trigger or helper function to constrain mutable columns.
- State-transition policies include an explicit transition comment.
- Non-admin `WITH CHECK` predicates are stricter than their `USING` predicates.

## Strict Transition Example

- Not needed for this fixture.
