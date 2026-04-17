# Supabase Patterns

## RLS Policies

```sql
-- ACCESS: authenticated users can read open rows; requester or admin can read non-open rows
CREATE POLICY restock_request_select_visible
  ON public.restock_request
  FOR SELECT TO authenticated
  USING (status = 'open' OR requested_by_user_id = auth.uid() OR public.is_admin(auth.uid()));

-- ACCESS: authenticated users can create their own request rows
CREATE POLICY restock_request_insert_self
  ON public.restock_request
  FOR INSERT TO authenticated
  WITH CHECK (requested_by_user_id = auth.uid());

CREATE FUNCTION public.restock_request_cancel_self_guard()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF OLD.status <> 'open' THEN
    RAISE EXCEPTION 'Only open rows can be cancelled';
  END IF;

  IF NEW.status <> 'cancelled' THEN
    RAISE EXCEPTION 'Status must move to cancelled';
  END IF;

  IF NEW.note IS DISTINCT FROM OLD.note OR NEW.snack_id IS DISTINCT FROM OLD.snack_id THEN
    RAISE EXCEPTION 'Only status and cancelled_at may change';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER restock_request_cancel_self_guard
  BEFORE UPDATE ON public.restock_request
  FOR EACH ROW
  EXECUTE FUNCTION public.restock_request_cancel_self_guard();

-- TRANSITION: requester can only move restock_request status from open to cancelled
-- ENFORCED BY: trigger restock_request_cancel_self_guard
-- ACCESS: requester can transition own open row to cancelled
CREATE POLICY restock_request_cancel_self
  ON public.restock_request
  FOR UPDATE TO authenticated
  USING (requested_by_user_id = auth.uid() AND status = 'open')
  WITH CHECK (requested_by_user_id = auth.uid() AND status = 'cancelled');
```

## RLS Lint Checklist

- Non-admin update paths use a trigger or helper function to constrain mutable columns.
- State-transition policies include an explicit transition comment.
- Non-admin `WITH CHECK` predicates are stricter than their `USING` predicates.

## Strict Transition Example

- `restock_request_cancel_self` uses `restock_request_cancel_self_guard` to reject edits outside the allowed `open` -> `cancelled` transition.
