# Supabase Patterns

## RLS Policies

```sql
-- ACCESS: authenticated users can read open rows; requester or admin can read non-open rows
CREATE POLICY restock_request_select_visible
  ON public.restock_request
  FOR SELECT TO authenticated
  USING (status = 'open' OR requested_by_user_id = auth.uid() OR public.is_admin(auth.uid()));
```
