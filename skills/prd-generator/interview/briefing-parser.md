# Briefing Parser

How to read the user's freeform briefing and assemble the 12-field checklist.

## The 12 key fields

| # | Field | What to look for in the briefing |
|---|---|---|
| 1 | **Project name** | Literal name ("BlogSaaS", "SlideGen", "ContentOps"). If absent, derive from the problem. |
| 2 | **Problem / objective** | "Why does it exist?" → one sentence that justifies the project. |
| 3 | **Target users** | Who uses it. CEOs? Internal devs? End B2B customers? B2C? |
| 4 | **Technical stack** | Framework mentioned (Next.js, Yii2, Rails, etc.). DB if mentioned. Hosting if mentioned. |
| 5 | **Authentication** | Email/password login? Social? SSO? MFA? Magic link? May be implicit (if internal B2B, probably SSO). |
| 6 | **Multi-tenant** | Keywords: "tenant", "multi-company", "each customer has their own", "isolation", "whitelabel", "portfolio". |
| 7 | **Roles / permissions** | Keywords: "admin", "user", "role", "permission", "owner", "viewer". |
| 8 | **Core entities** | Repeated nouns: "lead", "post", "slide deck", "campaign", "form submission". |
| 9 | **External integrations** | APIs mentioned (Stripe, OpenAI, Supabase, Meta Ads, etc.). Separate "definitely in" from "might need". |
| 10 | **MVP scope** | "To start", "v1", "MVP", "first milestone". |
| 11 | **Non-goals** | "Won't do", "later", "not included", "out of scope". |
| 12 | **Deploy / infra** | Hosting mentioned (Vercel, AWS, Docker, bare metal). Observability if mentioned. |

## Marking the checklist

For each field, classify:

- **✓ Complete** → briefing answers it clearly, no need to ask
- **? Partial** → there's a hint but a detail is missing, needs ONE follow-up
- **✗ Absent** → not mentioned, needs a full question

## Heuristics

### Reasonable defaults (to avoid over-asking)

- Owner of the PRD: derive from `git config user.name` if available, else ask. Never hardcode a specific person.
- Hosting if Next.js: Vercel
- Hosting if Yii2/PHP: Docker + DigitalOcean/AWS
- DB if Next.js: Supabase Postgres
- DB if Yii2: MySQL
- Versioning: always v1.0 for the initial PRD
- Observability: ask the user. If they have no preference, suggest Sentry as a common default.
- Commit convention: Conventional Commits (feat/fix/refactor/etc.)

### When multi-tenant is the DEFAULT

If the project is a SaaS where multiple companies/customers will share infrastructure with isolated data, multi-tenant is almost certain. Confirm anyway, but assume "yes" as the default.

If the project is a personal tool or a single-tenant internal app, multi-tenant is "no".

### When to ask vs. when to assume

- **Always ask:** multi-tenant (y/n), auth method, stack (if 2+ stacks plausible), MVP scope, non-goals.
- **Assume with default:** hosting, DB, observability, commit convention, versioning.
- **Always confirm before generating:** the full summary in Step 4.

## Expected output

After parsing, build a mental checklist in this format:

```
[✓] Name: BlogSaaS
[✓] Problem: a multi-tenant content platform for portfolio companies
[✗] Target users: (not stated) → ask
[?] Stack: "Next.js" mentioned, but backend? DB? → ask
[✗] Auth: (not stated) → ask
[✗] Multi-tenant: (not stated) → ask
...
```

Then use that checklist to compose the interview question batch.
