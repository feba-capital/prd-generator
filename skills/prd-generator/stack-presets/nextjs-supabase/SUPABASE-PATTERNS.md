# Supabase Multi-Tenant Patterns

**Architecture:** Single Postgres database, row-level isolation via `tenant_id` + Row Level Security (RLS)
**Enforcement:** RLS policies automatically filter queries. Bypassing requires service role key (server-side only).

---

## 1. Multi-Tenancy Model

This architecture uses **single-database multi-tenancy** with automatic enforcement via RLS:

- **User owns rows** → Each user can only see/modify their own tenant's data
- **Row Level Security (RLS)** → Database-level policies, not application-level
- **Tenant isolation** → Enforced by Postgres, not by buggy application code
- **Service role key** → Only on server-side, never in client code

### Tenant-Scoped Tables

Every table that belongs to a tenant has:
```sql
CREATE TABLE posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  user_id uuid NOT NULL,
  title text,
  created_at timestamptz DEFAULT now(),
  
  FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES auth.users (id) ON DELETE CASCADE
);

CREATE INDEX idx_posts_tenant_id ON posts (tenant_id);
```

### Global Tables (no tenant_id)

- `auth.users` → Platform accounts
- `tenants` → Tenant records (the container itself)
- `global_config` → App-level settings

---

## 2. Row Level Security (RLS) Policies

### 2.1 Enable RLS

Always enable RLS on tenant-scoped tables:

```sql
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
```

### 2.2 Basic Pattern: User Owns Their Tenant's Data

```sql
-- Policy: Users can only view their tenant's posts
CREATE POLICY "Users can view their tenant's posts" ON posts
  FOR SELECT
  USING (
    tenant_id = (
      SELECT tenant_id FROM auth.users 
      WHERE id = auth.uid()
    )
  );

-- Policy: Users can only insert into their tenant
CREATE POLICY "Users can insert into their tenant" ON posts
  FOR INSERT
  WITH CHECK (
    tenant_id = (
      SELECT tenant_id FROM auth.users 
      WHERE id = auth.uid()
    )
  );

-- Policy: Users can only update their tenant's posts
CREATE POLICY "Users can update their tenant's posts" ON posts
  FOR UPDATE
  USING (
    tenant_id = (
      SELECT tenant_id FROM auth.users 
      WHERE id = auth.uid()
    )
  )
  WITH CHECK (
    tenant_id = (
      SELECT tenant_id FROM auth.users 
      WHERE id = auth.uid()
    )
  );

-- Policy: Users can only delete their tenant's posts
CREATE POLICY "Users can delete their tenant's posts" ON posts
  FOR DELETE
  USING (
    tenant_id = (
      SELECT tenant_id FROM auth.users 
      WHERE id = auth.uid()
    )
  );
```

### 2.3 Store Tenant ID in JWT Claims (Faster)

Instead of looking up `auth.users` every query, store `tenant_id` in the JWT:

```sql
-- In Supabase, create a function that sets tenant_id as a JWT claim
CREATE OR REPLACE FUNCTION set_tenant_claim() RETURNS TRIGGER AS $$
BEGIN
  NEW.raw_app_meta_data := jsonb_set(
    COALESCE(NEW.raw_app_meta_data, '{}'::jsonb),
    '{tenant_id}',
    to_jsonb(NEW.tenant_id)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger on auth.users update
CREATE TRIGGER set_tenant_claim_trigger
  BEFORE INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION set_tenant_claim();
```

Then simplify RLS policies:

```sql
CREATE POLICY "Users can view their tenant's posts" ON posts
  FOR SELECT
  USING (
    tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
  );
```

### 2.4 Combine RLS with User-Level Checks

For operations that require specific user roles (e.g., "only editors can publish"):

```sql
CREATE POLICY "Only editors can publish" ON posts
  FOR UPDATE
  USING (
    tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    AND
    (auth.jwt() ->> 'role') = 'editor'
  )
  WITH CHECK (
    tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    AND
    (auth.jwt() ->> 'role') = 'editor'
  );
```

### 2.5 RLS Lint Checklist

Apply this checklist to every generated non-admin UPDATE policy:

1. If the policy targets `FOR UPDATE TO authenticated` and the `USING` clause references `auth.uid()`, the package MUST also document how column changes are constrained.
2. State transitions must be named explicitly in a comment immediately above the policy: `-- TRANSITION: open -> cancelled`.
3. Add a second comment immediately above the policy that points at the guard mechanism: `-- ENFORCED BY: trigger policy_guard_name` or `-- ENFORCED BY: function policy_guard_name`.
4. A loose `WITH CHECK` is not enough. Use a trigger or SECURITY DEFINER helper when the caller may only change a subset of columns.
5. `WITH CHECK` for non-admin UPDATE must be stricter than `USING`, never equal and never broader.

### 2.6 Strict Transition Example

Use this pattern when a non-admin user may perform exactly one state transition and no other field changes:

```sql
CREATE OR REPLACE FUNCTION public.restock_request_cancel_self_guard()
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

This is the baseline pattern to reuse whenever a requester-owned row supports only a narrow transition.

---

## 3. TypeScript Helpers for Tenant-Scoped Queries

### 3.1 Create a Supabase Client with Auth Context

```ts
// lib/db/supabase-client.ts
import { createBrowserClient } from "@supabase/ssr";
import type { Database } from "@/types/database";

export const supabase = createBrowserClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);
```

### 3.2 Query Tenant-Scoped Data

The browser client automatically includes the JWT in requests, so RLS filters apply:

```ts
// lib/db/posts.ts
import type { Database } from "@/types/database";
import { supabase } from "./supabase-client";

type Post = Database["public"]["Tables"]["posts"]["Row"];
type PostInsert = Database["public"]["Tables"]["posts"]["Insert"];

export async function getPosts(): Promise<Post[]> {
  const { data, error } = await supabase
    .from("posts")
    .select("*")
    .order("created_at", { ascending: false });

  if (error) throw error;
  // RLS automatically filters to the user's tenant
  return data || [];
}

export async function createPost(input: PostInsert): Promise<Post> {
  const { data, error } = await supabase
    .from("posts")
    .insert([input])
    .select()
    .single();

  if (error) throw error;
  return data;
}
```

### 3.3 Server-Side Queries (Service Role)

Use the service role key only on the server to bypass RLS (e.g., for admin operations):

```ts
// lib/db/supabase-server.ts
import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/types/database";

export const supabaseAdmin = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY! // ← never expose to client
);
```

```ts
// lib/db/admin.ts
import { supabaseAdmin } from "./supabase-server";

export async function getAllPostsAcrossAllTenants() {
  // This bypasses RLS, only use for admin operations
  const { data, error } = await supabaseAdmin
    .from("posts")
    .select("*, tenants(*)")
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data;
}
```

---

## 4. Multi-Tenant Database Schema Example

### 4.1 Core Tables

```sql
-- Tenants (the containers)
CREATE TABLE tenants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Users (platform accounts)
CREATE TABLE auth.users (
  id uuid PRIMARY KEY,
  email text UNIQUE NOT NULL,
  tenant_id uuid NOT NULL REFERENCES tenants (id),
  role text DEFAULT 'member', -- 'owner', 'editor', 'member'
  created_at timestamptz DEFAULT now()
);

-- Posts (tenant-owned)
CREATE TABLE posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants (id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  title text NOT NULL,
  content text,
  published boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Comments (tenant-owned)
CREATE TABLE comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants (id) ON DELETE CASCADE,
  post_id uuid NOT NULL REFERENCES posts (id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  text text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS on all tenant-scoped tables
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
```

### 4.2 RLS Policies for All Tables

```sql
-- Posts: Users can only see their tenant's posts
CREATE POLICY "Users see their tenant's posts" ON posts
  FOR SELECT
  USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY "Users insert into their tenant" ON posts
  FOR INSERT
  WITH CHECK (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY "Users update their tenant's posts" ON posts
  FOR UPDATE
  USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid)
  WITH CHECK (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY "Users delete their tenant's posts" ON posts
  FOR DELETE
  USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

-- Comments: Same pattern
CREATE POLICY "Users see their tenant's comments" ON comments
  FOR SELECT
  USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY "Users insert into their tenant" ON comments
  FOR INSERT
  WITH CHECK (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY "Users update their tenant's comments" ON comments
  FOR UPDATE
  USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid)
  WITH CHECK (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY "Users delete their tenant's comments" ON comments
  FOR DELETE
  USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
```

---

## 5. Testing Tenant Isolation

### 5.1 E2E Test: Verify Users See Only Their Tenant's Data

```ts
// e2e/tenant-isolation.spec.ts
import { test, expect } from "@playwright/test";

test("User A cannot see User B's posts", async ({ browser }) => {
  // Context A → User A's tenant
  const contextA = await browser.newContext({
    httpCredentials: {
      username: "user-a@example.com",
      password: "password-a",
    },
  });
  const pageA = await contextA.newPage();

  // Create a post as User A
  await pageA.goto("/posts/new");
  await pageA.fill("input[name=title]", "Post by User A");
  await pageA.click("button[type=submit]");
  await expect(pageA).toHaveURL("/posts");

  // Context B → User B's tenant (different tenant)
  const contextB = await browser.newContext({
    httpCredentials: {
      username: "user-b@example.com",
      password: "password-b",
    },
  });
  const pageB = await contextB.newPage();

  // User B tries to see User A's posts
  await pageB.goto("/posts");

  // Should NOT see User A's post
  await expect(pageB.locator("text=Post by User A")).not.toBeVisible();

  await contextA.close();
  await contextB.close();
});
```

### 5.2 Database-Level Test: RLS Enforces Isolation

```sql
-- Test 1: User from tenant A cannot see tenant B's data
-- (This would require a test framework that simulates different JWT tokens)

-- Test 2: Verify indexes exist for performance
SELECT * FROM pg_indexes WHERE tablename IN ('posts', 'comments');

-- Test 3: Verify RLS policies are active
SELECT * FROM pg_policies WHERE tablename IN ('posts', 'comments');
```

---

## 6. Common Pitfalls & Solutions

### Pitfall 1: Forgetting to Add tenant_id to INSERT

```ts
// ✗ BAD
await supabase
  .from("posts")
  .insert([{ title: "Hello", content: "..." }])
  .select()
  .single();

// ✓ GOOD
const { data: { user } } = await supabase.auth.getUser();
const tenantId = user?.user_metadata?.tenant_id;

await supabase
  .from("posts")
  .insert([{ 
    tenant_id: tenantId, // ← add this
    title: "Hello", 
    content: "..." 
  }])
  .select()
  .single();
```

### Pitfall 2: Disabling RLS for Convenience

```sql
-- BAD: never do this
ALTER TABLE posts DISABLE ROW LEVEL SECURITY;

-- GOOD: RLS should always be enabled in production
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
```

### Pitfall 3: Using Service Role Key in Client Code

```tsx
// BAD: exposes service role key, bypasses RLS
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY // ← NEVER expose this
);

// GOOD: use anon key in browser, service role only on server
const supabase = createBrowserClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY // ← safe for browser
);
```

### Pitfall 4: Missing Indexes on tenant_id

```sql
-- BAD: slow queries
-- RLS filters on tenant_id but no index

-- GOOD: index for performance
CREATE INDEX idx_posts_tenant_id ON posts (tenant_id);
CREATE INDEX idx_posts_tenant_user ON posts (tenant_id, user_id);
CREATE INDEX idx_comments_tenant_id ON comments (tenant_id);
```

### Pitfall 5: Not Enforcing tenant_id in Migrations

```sql
-- BAD: migration doesn't set tenant_id constraint
CREATE TABLE posts (
  id uuid PRIMARY KEY,
  title text
);

-- GOOD: tenant_id is required, indexed, and referenced
CREATE TABLE posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants (id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  title text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_posts_tenant_id ON posts (tenant_id);
```

---

## 7. Security Checklist

- [ ] RLS enabled on all tenant-scoped tables
- [ ] RLS policies check `tenant_id` matches JWT claim
- [ ] Service role key never exposed in client code
- [ ] All INSERT/UPDATE/DELETE include `tenant_id`
- [ ] All SELECT filters on `tenant_id` (RLS does this automatically)
- [ ] Indexes on `tenant_id` exist for performance
- [ ] Foreign keys cascade delete on tenant deletion
- [ ] Tests verify users cannot access other tenants' data
- [ ] Error messages don't leak record existence across tenants (always 404)
- [ ] Audit logs record cross-tenant access attempts (if admin features exist)

---

## 8. Migration Checklist (for New Tenant-Scoped Tables)

- [ ] Add `tenant_id uuid NOT NULL` column
- [ ] Add foreign key to `tenants` table with `ON DELETE CASCADE`
- [ ] Add index on `tenant_id`
- [ ] Enable RLS: `ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;`
- [ ] Create RLS SELECT policy (scoped to tenant)
- [ ] Create RLS INSERT policy (scoped to tenant)
- [ ] Create RLS UPDATE policy (scoped to tenant)
- [ ] Create RLS DELETE policy (scoped to tenant)
- [ ] Test isolation: same query, different tenants, returns different results
- [ ] Document in this file if the policy pattern is unusual
