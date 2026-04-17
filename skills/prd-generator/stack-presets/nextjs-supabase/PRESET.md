# Next.js + Supabase + Vercel Preset

**Stack:** Next.js 14 (App Router), TypeScript, Supabase Postgres (RLS), Tailwind CSS, Vercel
**Use-case:** Modern, full-stack web applications with built-in auth, multi-tenant isolation, and edge deployment

---

## Arquivos fornecidos

- **NEXTJS-BEST-PRACTICES.md** → Coding standards, Server/Client components, data fetching, forms, error handling, testing
- **SUPABASE-PATTERNS.md** → Row Level Security (RLS), multi-tenant data isolation, security checklist

---

## Development Workflow Placeholders

| Task | Command |
|------|---------|
| Dev server | `npm run dev` (localhost:3000) |
| Build | `npm run build` |
| Production | `npm start` |
| Type check | `npm run type-check` or `tsc --noEmit` |
| Linting | `npm run lint` (ESLint) |
| Format | `npm run format` (Biome) |
| Tests (unit) | `npm run test` (Vitest) |
| Tests (E2E) | `npm run test:e2e` (Playwright) |
| DB migrations | `supabase migration new {name}` → `supabase db push` |
| Generate types | `supabase gen types typescript --project-id {id}` |

---

## Naming Conventions

| Item | Pattern | Example |
|------|---------|---------|
| Route (folder) | kebab-case | `app/blog-posts/` |
| Route (page) | `page.tsx` | `app/blog-posts/page.tsx` |
| Route param | `[param].tsx` | `app/posts/[id]/page.tsx` |
| Component | PascalCase.tsx | `components/PostCard.tsx` |
| Component prop type | `{Name}Props` | `interface PostCardProps { }` |
| API route | `route.ts` | `app/api/posts/route.ts` |
| Server action | camelCase | `lib/actions/createPost.ts` |
| Database type | `Database` (from generated) | `type Post = Database["public"]["Tables"]["posts"]["Row"]` |
| Hook | `use{Name}` | `lib/hooks/usePosts.ts` |
| Util function | camelCase | `lib/utils/formatDate.ts` |
| DB table | snake_case | `posts`, `user_profiles` |
| DB column | snake_case | `created_at`, `tenant_id`, `user_id` |
| DB constraint | `fk_`, `idx_`, `pk_` prefix | `fk_posts_user_id`, `idx_posts_tenant_id` |
| Constant | UPPER_SNAKE_CASE | `MAX_POST_LENGTH`, `API_TIMEOUT_MS` |

---

## Default Infrastructure

| Component | Standard |
|-----------|----------|
| Hosting | Vercel (automatic deployments on push to main) |
| Database | Supabase Postgres (managed, with auto-backups) |
| Auth | Supabase Auth (JWT, magic links, OAuth via Supabase) |
| Real-time | Supabase Realtime (WebSockets for live updates) |
| Edge functions | Vercel Edge Functions (optional, for low-latency APIs) |
| File storage | Supabase Storage (S3-compatible) |
| Secrets | Vercel Environment Variables (NEXT_PUBLIC_* for client-side) |
| Monitoring | Vercel Analytics (built-in) |
| Error tracking | Sentry (recommended, optional) |
| Email | Resend (recommended) or SendGrid |

---

## Key Files Structure

```
src/
├── app/
│   ├── layout.tsx              (root layout, auth listener)
│   ├── page.tsx                (home page)
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   ├── signup/page.tsx
│   │   └── callback/route.ts   (OAuth callback)
│   ├── (dashboard)/
│   │   ├── layout.tsx          (protected layout)
│   │   ├── page.tsx            (dashboard home)
│   │   └── posts/
│   │       ├── page.tsx        (list)
│   │       ├── new/page.tsx    (create)
│   │       ├── [id]/page.tsx   (view)
│   │       └── [id]/edit/page.tsx
│   ├── api/
│   │   ├── posts/route.ts      (POST /api/posts, etc.)
│   │   └── auth/callback/route.ts
│   └── error.tsx, not-found.tsx, loading.tsx
├── components/
│   ├── PostCard.tsx
│   ├── PostForm.tsx
│   ├── SupabaseListener.tsx    (auth state listener)
│   └── ui/                     (shadcn/ui or custom)
├── lib/
│   ├── db/
│   │   ├── supabase.ts         (server client)
│   │   ├── supabase-browser.ts (client-side)
│   │   ├── auth.ts             (getCurrentUser, etc.)
│   │   └── posts.ts            (queries)
│   ├── actions/
│   │   ├── posts.ts            (Server Actions)
│   │   └── auth.ts
│   ├── hooks/
│   │   ├── usePosts.ts
│   │   └── useAuth.ts
│   ├── utils/
│   │   ├── formatDate.ts
│   │   └── cn.ts               (Tailwind utility)
│   ├── validations/
│   │   └── post.ts             (Zod schemas)
│   └── middleware.ts           (Next.js middleware for protected routes)
├── types/
│   ├── database.ts             (generated from supabase)
│   ├── posts.ts                (app-specific types)
│   └── auth.ts
├── styles/
│   ├── globals.css             (Tailwind, global styles)
│   └── variables.css           (CSS variables)
└── tests/
    ├── e2e/                    (Playwright tests)
    ├── unit/                   (Vitest tests)
    └── fixtures/               (test data)
```

---

## Performance Considerations

- **ISR (Incremental Static Regeneration)** → Cache pages with `revalidate`, update on-demand
- **Server Components** → Default for all routes, no JavaScript shipped to client
- **Image optimization** → Use `next/image` for automatic lazy-loading, format conversion
- **Font optimization** → Use `next/font` to avoid layout shift
- **Code splitting** → Automatic per-route, use `dynamic()` for large components
- **RLS on database** → Queries filtered at database layer, not in application
- **Edge caching** → Cache static assets (CSS, images) at edge, served globally

---

## Security Baseline

- **RLS on all tenant-scoped tables** → Automatic tenant isolation at database layer
- **Environment secrets** → Never expose `SUPABASE_SERVICE_ROLE_KEY` in browser (Vercel secrets, not `NEXT_PUBLIC_`)
- **Auth cookies** → Supabase manages httpOnly, Secure cookies (no localStorage)
- **CSRF protection** → Built into Next.js (token in forms)
- **Rate limiting** → Configure on Vercel or Supabase PostgreSQL
- **Input validation** → Use Zod for form inputs + Server Actions
- **Type safety** → Strict TypeScript catches many bugs at build time
- **Error messages** → Never leak record existence or system details to client

---

## When to Use This Preset

✓ Modern full-stack applications (frontend + backend in one repo)
✓ Multi-tenant SaaS platforms (with RLS isolation)
✓ Real-time collaborative apps (with Supabase Realtime)
✓ Teams comfortable with React + TypeScript
✓ Projects deployed on Vercel
✓ Fast time-to-market (Supabase + Next.js templates available)

✗ Not ideal for API-only backends (use Next.js as API or a different framework)
✗ Not ideal if you need heavy real-time (consider Socket.io separately)
✗ Not ideal for pure static sites (use Astro or Hugo instead)
✗ Not ideal for PHP / Python backends that already exist

---

## Learning Resources

- [Next.js 14 Docs](https://nextjs.org/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [Vercel Deployment](https://vercel.com/docs)

---

## Next Steps After Project Init

1. Copy `supabase/migrations/` folder from template, set up local Postgres
2. Run `supabase start` to spin up local Supabase
3. Create `types/database.ts` via `supabase gen types typescript`
4. Set up `lib/db/supabase.ts` (server) and `lib/db/supabase-browser.ts` (client)
5. Create `components/SupabaseListener.tsx` for auth state sync
6. Build protected layout + auth pages (login, signup, logout)
7. Set up first data table with RLS policies (see SUPABASE-PATTERNS.md)
8. Create API routes or Server Actions for mutations
9. Add E2E tests with Playwright (see NEXTJS-BEST-PRACTICES.md)
10. Deploy to Vercel: connect GitHub repo, add environment variables, auto-deploy on push

---

## Environment Variables Checklist

**`NEXT_PUBLIC_` variables (exposed to client, safe):**
- `NEXT_PUBLIC_SUPABASE_URL` → from Supabase project settings
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` → from Supabase project settings
- `NEXT_PUBLIC_APP_URL` → https://yourdomain.com (for OAuth callbacks)

**Server-only variables (never NEXT_PUBLIC_):**
- `SUPABASE_SERVICE_ROLE_KEY` → keep secret, use on server only
- `DATABASE_URL` → optional, for direct Postgres access
- `API_SECRET_KEY` → any app-specific secrets

**Vercel-specific:**
- All variables go into Vercel project settings
- Local `.env.local` mirrors structure for development
- Preview deployments inherit prod secrets by default
