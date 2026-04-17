# Supabase Patterns

## RLS Policies

```sql
CREATE POLICY restock_request_cancel_self
  ON public.restock_request
  FOR UPDATE TO authenticated
  USING (requested_by_user_id = auth.uid() AND status = 'open')
  WITH CHECK (requested_by_user_id = auth.uid() AND status IN ('open', 'cancelled'));
```
