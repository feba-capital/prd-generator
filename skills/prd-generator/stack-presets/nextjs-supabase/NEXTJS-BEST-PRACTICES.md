# Next.js Best Practices

**Applies to:** All TypeScript code in `app/`, `components/`, `lib/`, `types/`
**Standard:** Next.js 14 (App Router), Strict TypeScript, ESLint, Biome formatter
**Target:** Production-ready, maintainable, type-safe React applications on Vercel

---

## 1. Project Architecture

This project uses **Next.js 14 App Router** with the following structure:

```
src/
├── app/                  (routes, layouts, pages)
├── components/           (UI components)
├── lib/                  (utilities, services, helpers)
├── types/                (TypeScript types, interfaces)
├── styles/               (global CSS, Tailwind config)
└── public/               (static assets)
```

### App Router Basics

- `app/` contains the router structure (one folder = one route segment)
- `layout.tsx` defines shared UI for a route and its children
- `page.tsx` is the actual page component
- `error.tsx` catches errors in the segment and below
- `loading.tsx` shows fallback UI while page loads
- `not-found.tsx` shows custom 404 for segment

Example structure:
```
app/
├── layout.tsx                (root layout)
├── page.tsx                  (home page)
├── (dashboard)/
│   ├── layout.tsx            (dashboard layout)
│   ├── page.tsx              (dashboard home)
│   └── posts/
│       ├── page.tsx          (/dashboard/posts)
│       ├── [id]/
│       │   └── page.tsx      (/dashboard/posts/[id])
│       └── loading.tsx       (fallback while /posts loads)
└── api/
    └── posts/
        └── route.ts          (API route, POST/GET/DELETE)
```

---

## 2. Server vs Client Components

### 2.1 Default to Server Components

By default, all components in `app/` are Server Components. This is the right choice 95% of the time:

```tsx
// app/posts/page.tsx — Server Component (default)
// ✓ Can query databases directly
// ✓ Keeps secrets (API keys, tokens) safe
// ✓ No JavaScript shipped to client
// ✓ Can use async directly

import { getPosts } from "@/lib/db/posts";

export default async function PostsPage() {
  const posts = await getPosts();
  
  return (
    <div>
      {posts.map(post => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  );
}
```

### 2.2 When to Use Client Components

Use `"use client"` when you need:
- React hooks (`useState`, `useEffect`, `useContext`)
- Event listeners (`onClick`, `onChange`)
- Browser APIs (`localStorage`, `window`)
- Real-time updates via useEffect

```tsx
// components/PostForm.tsx — Client Component
"use client";

import { useState } from "react";
import { createPost } from "@/lib/actions/posts";

export function PostForm() {
  const [title, setTitle] = useState("");
  const [loading, setLoading] = useState(false);
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await createPost({ title });
      setTitle("");
    } finally {
      setLoading(false);
    }
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <input 
        value={title} 
        onChange={e => setTitle(e.target.value)}
        placeholder="Post title"
      />
      <button disabled={loading} type="submit">
        {loading ? "Creating..." : "Create"}
      </button>
    </form>
  );
}
```

### 2.3 Server Actions

Server Actions are the preferred way to mutate data. They're async functions in Server Components that run on the server:

```tsx
// lib/actions/posts.ts
"use server";

import { revalidatePath } from "next/cache";
import { createPostInDb } from "@/lib/db/posts";

export async function createPost(formData: FormData) {
  const title = formData.get("title") as string;
  
  if (!title) {
    throw new Error("Title is required");
  }
  
  const post = await createPostInDb({ title });
  
  // Revalidate the posts page so users see the new post immediately
  revalidatePath("/posts");
  
  return post;
}
```

Then call from a Client Component form:

```tsx
"use client";

import { createPost } from "@/lib/actions/posts";

export function PostForm() {
  return (
    <form action={createPost}>
      <input 
        name="title"
        placeholder="Post title"
        required
      />
      <button type="submit">Create</button>
    </form>
  );
}
```

### 2.4 Data Fetching Pattern

**Server Component** → fetch data → pass to **Client Component**:

```tsx
// app/dashboard/page.tsx (Server)
import { getUserStats } from "@/lib/db/stats";
import { StatsChart } from "@/components/StatsChart";

export default async function DashboardPage() {
  const stats = await getUserStats();
  
  // Pass data as props to Client Component
  return <StatsChart initialData={stats} />;
}
```

```tsx
// components/StatsChart.tsx (Client)
"use client";

import { useState } from "react";
import type { Stats } from "@/types/stats";

interface StatsChartProps {
  initialData: Stats;
}

export function StatsChart({ initialData }: StatsChartProps) {
  const [stats, setStats] = useState(initialData);
  
  // Client-side interactivity with server data
  return <div>{/* render stats */}</div>;
}
```

---

## 3. TypeScript & Type Safety

### 3.1 Strict Mode Always

`tsconfig.json` MUST have:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "noImplicitThis": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

### 3.2 Function Types

Every function must have explicit parameter and return types:

```tsx
// ✗ BAD — missing types
function getUserStats(userId) {
  return fetch(`/api/stats/${userId}`).then(r => r.json());
}

// ✓ GOOD — full types
async function getUserStats(userId: string): Promise<UserStats> {
  const res = await fetch(`/api/stats/${userId}`);
  
  if (!res.ok) {
    throw new Error(`Failed to fetch stats: ${res.status}`);
  }
  
  return res.json();
}
```

### 3.3 Component Props

Define prop types using interfaces or `React.FC`:

```tsx
interface PostCardProps {
  post: Post;
  isHighlighted?: boolean;
  onDelete: (id: string) => void;
}

export function PostCard({ 
  post, 
  isHighlighted = false, 
  onDelete 
}: PostCardProps) {
  return (
    <div>
      <h2>{post.title}</h2>
      <button onClick={() => onDelete(post.id)}>
        Delete
      </button>
    </div>
  );
}
```

### 3.4 Avoid `any`

Never use `any`. Use `unknown` if you truly don't know the type, then narrow it:

```tsx
// ✗ BAD
function processData(data: any) {
  return data.title.toUpperCase();
}

// ✓ GOOD
function processData(data: unknown): string {
  if (typeof data !== "object" || data === null) {
    throw new Error("Expected object");
  }
  
  if (!("title" in data) || typeof data.title !== "string") {
    throw new Error("Expected title string");
  }
  
  return data.title.toUpperCase();
}
```

### 3.5 Typed Database Queries (Supabase)

Generate TypeScript types from your Supabase schema:

```bash
npx supabase gen types typescript --project-id your_id > types/database.ts
```

Use in your code:

```tsx
import type { Database } from "@/types/database";

type Post = Database["public"]["Tables"]["posts"]["Row"];
type PostInsert = Database["public"]["Tables"]["posts"]["Insert"];

async function createPost(data: PostInsert): Promise<Post> {
  // ...
}
```

---

## 4. Data Fetching & Caching

### 4.1 Server-Side Data Fetching

Use `async` in Server Components:

```tsx
// app/posts/page.tsx
import { getAllPosts } from "@/lib/db/posts";

export default async function PostsPage() {
  const posts = await getAllPosts();
  return <PostList posts={posts} />;
}
```

### 4.2 Supabase Client (Server-Side)

Use the server-side Supabase client in Server Components and Server Actions:

```tsx
// lib/db/supabase.ts
import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/types/database";

export const supabase = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY! // ← never expose in client
);
```

### 4.3 Supabase Client (Client-Side)

For auth and client-side queries, use the browser client:

```tsx
// lib/db/supabase-browser.ts
import { createBrowserClient } from "@supabase/ssr";
import type { Database } from "@/types/database";

export const supabase = createBrowserClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);
```

### 4.4 Caching with `revalidate`

Control caching per-request:

```tsx
// Cache for 1 hour
export const revalidate = 3600;

// Don't cache (always fetch fresh)
export const revalidate = 0;

// ISR: Revalidate at most once per hour, on-demand via revalidatePath
export const revalidate = 3600;
```

Or in `fetch` calls:

```tsx
const res = await fetch("/api/data", {
  next: { revalidate: 3600 } // cache for 1 hour
});
```

### 4.5 Revalidation

Manually invalidate cache after mutations:

```tsx
"use server";

import { revalidatePath } from "next/cache";

export async function updatePost(id: string, data: PostData) {
  // Update in database
  await db.posts.update(id, data);
  
  // Invalidate cached pages that show this post
  revalidatePath(`/posts/${id}`);
  revalidatePath("/posts"); // Also update the list
}
```

---

## 5. Supabase Integration

### 5.1 Auth Setup (Next.js)

Use the Supabase Auth Helpers:

```tsx
// app/layout.tsx
import { SupabaseListener } from "@/components/SupabaseListener";

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html>
      <body>
        <SupabaseListener />
        {children}
      </body>
    </html>
  );
}
```

```tsx
// components/SupabaseListener.tsx
"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { supabase } from "@/lib/db/supabase-browser";

export function SupabaseListener() {
  const router = useRouter();

  useEffect(() => {
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(() => {
      router.refresh(); // Refresh Server Components
    });

    return () => {
      subscription.unsubscribe();
    };
  }, [router]);

  return null;
}
```

### 5.2 Getting the Current User (Server)

```tsx
// lib/db/auth.ts
import { cookies } from "next/headers";
import { supabase } from "./supabase";

export async function getCurrentUser() {
  const cookieStore = cookies();
  const token = cookieStore.get("sb-access-token")?.value;

  if (!token) {
    return null;
  }

  const {
    data: { user },
  } = await supabase.auth.getUser(token);

  return user;
}
```

```tsx
// app/dashboard/page.tsx
import { getCurrentUser } from "@/lib/db/auth";
import { redirect } from "next/navigation";

export default async function DashboardPage() {
  const user = await getCurrentUser();

  if (!user) {
    redirect("/login");
  }

  return <div>Welcome, {user.email}</div>;
}
```

### 5.3 Row Level Security (RLS)

Enable RLS on all tables. Policies automatically filter data:

```sql
-- posts table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Users can only see their own posts
CREATE POLICY "Users can view their posts" ON posts
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can only insert their own posts
CREATE POLICY "Users can insert their own posts" ON posts
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

Use in app (RLS enforces filtering automatically):

```tsx
export async function getUserPosts(userId: string) {
  const { data, error } = await supabase
    .from("posts")
    .select("*")
    .eq("user_id", userId)
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data;
}
```

---

## 6. Forms & Validation

### 6.1 Server Actions + Zod

Validate form input with Zod:

```tsx
// lib/validations/post.ts
import { z } from "zod";

export const postSchema = z.object({
  title: z.string().min(1).max(255),
  content: z.string().min(1),
  published: z.boolean().optional().default(false),
});

export type PostInput = z.infer<typeof postSchema>;
```

### 6.2 Form Component with Server Action

```tsx
// app/posts/new/page.tsx
"use client";

import { useState } from "react";
import { useFormState } from "react-dom";
import { createPost } from "@/lib/actions/posts";

export default function NewPostPage() {
  const [formState, formAction] = useFormState(createPost, null);

  return (
    <form action={formAction}>
      <input 
        name="title" 
        placeholder="Title"
        required
      />
      
      <textarea 
        name="content" 
        placeholder="Content"
        required
      />
      
      <label>
        <input type="checkbox" name="published" />
        Publish
      </label>
      
      <button type="submit">Create Post</button>
      
      {formState?.error && (
        <p style={{ color: "red" }}>{formState.error}</p>
      )}
    </form>
  );
}
```

### 6.3 Server Action with Validation

```tsx
// lib/actions/posts.ts
"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { supabase } from "@/lib/db/supabase";
import { postSchema } from "@/lib/validations/post";
import { getCurrentUser } from "@/lib/db/auth";

export async function createPost(
  _prevState: unknown,
  formData: FormData
) {
  try {
    const user = await getCurrentUser();
    
    if (!user) {
      return { error: "Not authenticated" };
    }

    // Parse and validate
    const input = Object.fromEntries(formData);
    const data = postSchema.parse(input);

    // Save to database
    const { data: post, error } = await supabase
      .from("posts")
      .insert([
        {
          ...data,
          user_id: user.id,
        },
      ])
      .select()
      .single();

    if (error) throw error;

    // Revalidate and redirect
    revalidatePath("/posts");
    redirect(`/posts/${post.id}`);
  } catch (error) {
    return {
      error: error instanceof Error ? error.message : "Something went wrong",
    };
  }
}
```

---

## 7. Error Handling

### 7.1 Error Boundary (error.tsx)

Each segment can have an `error.tsx` that catches errors from children:

```tsx
// app/posts/error.tsx
"use client";

import { useEffect } from "react";

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Log to error reporting service
    console.error(error);
  }, [error]);

  return (
    <div>
      <h2>Something went wrong</h2>
      <button onClick={() => reset()}>Try again</button>
    </div>
  );
}
```

### 7.2 Not Found (not-found.tsx)

Show custom 404 for a segment:

```tsx
// app/posts/[id]/not-found.tsx
export default function NotFound() {
  return (
    <div>
      <h2>Post not found</h2>
      <p>Sorry, we couldn't find the post you're looking for.</p>
    </div>
  );
}
```

### 7.3 Throwing Errors in Server Components

```tsx
import { notFound } from "next/navigation";

export default async function PostPage({
  params,
}: {
  params: { id: string };
}) {
  const post = await getPost(params.id);

  if (!post) {
    notFound(); // Shows not-found.tsx
  }

  return <PostDetail post={post} />;
}
```

---

## 8. Loading States (loading.tsx)

Show a skeleton while page loads:

```tsx
// app/posts/loading.tsx
export default function Loading() {
  return (
    <div>
      <div className="h-4 bg-gray-200 rounded animate-pulse" />
      <div className="h-4 bg-gray-200 rounded animate-pulse mt-4" />
    </div>
  );
}
```

Or use Suspense for granular control:

```tsx
import { Suspense } from "react";

export default function PostPage() {
  return (
    <div>
      <h1>Posts</h1>
      <Suspense fallback={<PostsSkeleton />}>
        <PostsList />
      </Suspense>
    </div>
  );
}
```

---

## 9. API Routes

Use `app/api/` for backend routes. Keep them thin, delegate to services:

```tsx
// app/api/posts/route.ts
import { getCurrentUser } from "@/lib/db/auth";
import { getUserPosts } from "@/lib/db/posts";
import { NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  try {
    const user = await getCurrentUser();

    if (!user) {
      return NextResponse.json(
        { error: "Unauthorized" },
        { status: 401 }
      );
    }

    const posts = await getUserPosts(user.id);
    return NextResponse.json(posts);
  } catch (error) {
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
```

---

## 10. Code Style Quick Reference

| Rule | Standard |
|---|---|
| String quotes | Double quotes `"string"` |
| Semicolons | Always use them |
| Arrow functions | Prefer for callbacks |
| Naming (components) | PascalCase |
| Naming (functions) | camelCase |
| Naming (constants) | UPPER_SNAKE_CASE |
| Indentation | 2 spaces (Next.js default) |
| Imports | Group: React → Next → relative |
| Type imports | `import type { Foo } from "..."` |
| CSS | Tailwind classes, avoid inline styles |

---

## 11. Anti-Patterns to Avoid

### Do NOT fetch data in useEffect from Client Component
```tsx
// ✗ BAD — race conditions, memory leaks
"use client";
import { useEffect, useState } from "react";

export function Posts() {
  const [posts, setPosts] = useState([]);

  useEffect(() => {
    fetch("/api/posts")
      .then(r => r.json())
      .then(setPosts);
  }, []); // Missing dependency can cause infinite loops
}

// ✓ GOOD — fetch in Server Component
export default async function PostsPage() {
  const posts = await getPosts();
  return <PostList posts={posts} />;
}
```

### Do NOT pass sensitive data to Client Components
```tsx
// ✗ BAD — API key exposed to client
export default async function Page() {
  const apiKey = process.env.SECRET_API_KEY; // ✗ Don't pass this
  return <Component apiKey={apiKey} />;
}

// ✓ GOOD — keep secret on server
export default async function Page() {
  const data = await fetchWithSecret(); // ✓ Fetch server-side
  return <Component data={data} />;
}
```

### Do NOT use Server Actions from API routes
```tsx
// ✗ BAD — Server Actions are not API routes
// lib/actions/post.ts
"use server";

export async function createPost(data) {
  // This can't be called from API routes, only forms
}

// ✓ GOOD — create an API route if you need HTTP access
// app/api/posts/route.ts
export async function POST(request: NextRequest) {
  const data = await request.json();
  const post = await createPostInDb(data);
  return NextResponse.json(post);
}
```

### Do NOT forget dependency arrays in useEffect
```tsx
// ✗ BAD
useEffect(() => {
  setCount(count + 1);
}); // Runs every render!

// ✓ GOOD
useEffect(() => {
  setCount(count + 1);
}, [count]); // Only when count changes
```

### Do NOT store auth tokens in localStorage
```tsx
// ✗ BAD — vulnerable to XSS
localStorage.setItem("token", token);

// ✓ GOOD — use httpOnly cookies (Supabase handles this)
// Supabase automatically manages cookies for you
```

---

## 12. Testing Strategy

### 12.1 Unit Tests (Vitest)

Test functions and utilities:

```tsx
// lib/utils.ts
export function formatDate(date: Date): string {
  return date.toLocaleDateString();
}
```

```tsx
// lib/utils.test.ts
import { describe, it, expect } from "vitest";
import { formatDate } from "./utils";

describe("formatDate", () => {
  it("formats date correctly", () => {
    const date = new Date("2025-04-14");
    expect(formatDate(date)).toBe("4/14/2025");
  });
});
```

### 12.2 E2E Tests (Playwright)

Test user flows:

```tsx
// e2e/posts.spec.ts
import { test, expect } from "@playwright/test";

test("user can create a post", async ({ page }) => {
  await page.goto("/posts/new");
  await page.fill("input[name=title]", "My Post");
  await page.fill("textarea[name=content]", "Content");
  await page.click("button[type=submit]");
  
  await expect(page).toHaveURL("/posts");
  await expect(page.locator("text=My Post")).toBeVisible();
});
```

---

## 13. Performance Optimization

- **Code splitting**: Next.js does this automatically
- **Image optimization**: Use `next/image` instead of `<img>`
- **Font optimization**: Use `next/font` for web fonts
- **Script optimization**: Use `next/script` with `strategy="lazyOnload"`
- **Bundle analysis**: `npm run build` shows bundle size
- **Lazy loading**: Use `dynamic()` for heavy components

```tsx
import dynamic from "next/dynamic";

const HeavyComponent = dynamic(() => import("@/components/Heavy"), {
  loading: () => <div>Loading...</div>,
});

export default function Page() {
  return <HeavyComponent />;
}
```

---

## Deployment Checklist

- [ ] All environment variables set in Vercel
- [ ] Database connection tested
- [ ] Auth configured in Supabase
- [ ] RLS policies enabled on all tables
- [ ] Error boundaries in place
- [ ] 404 / error pages customized
- [ ] Loading states for slow endpoints
- [ ] Images optimized with `next/image`
- [ ] API routes typed and validated
- [ ] Sensitive data never exposed to client
- [ ] `revalidate` / `revalidatePath` configured
- [ ] Tests passing locally
