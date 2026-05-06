# Interview Question Bank

Question bank by field. Use when the briefing has ✗ or ?. Formulate via the `AskUserQuestion` tool, in batches of 2-4.

---

## Batch 1 - Foundation (if any are missing, ask together)

### Project name
**Q:** "What is the official name of this project?"
- Free text (no options). A slug must be derivable.

### Primary target users
**Q:** "Who is the primary user of this product?"
- Options: Internal employees / operators | External B2B customers | End B2C customers | Developers (devtools) | Mixed | Other

### One-liner / core problem
**Q:** "In one sentence: what is the main problem this project solves?"
- Free text. Goes into the Tagline field of the PRD.

---

## Batch 2 - Project Type & Stack

### Project type
**Q:** "What kind of project is this?"
- Options: **Fullstack web app** (frontend + backend + DB) | **Backend API only** (no UI of its own, serves APIs) | **Mobile app** (iOS/Android client, with or without its own backend) | **Browser extension** | **CLI tool / script** | **Desktop app** | Other

→ This decides which templates run:
- `fullstack web app` → PRD + AGENTS + dev-workflow + api-docs/endpoints/models/controllers + CLAUDE + README + CHANGELOG
- `backend api only` → same as fullstack, without UI docs
- `mobile app` → PRD + AGENTS + dev-workflow + screens.md + state-model.md + (api-* if it has its own backend) + CLAUDE + README + CHANGELOG
- `browser extension` → PRD + AGENTS + dev-workflow + manifest-spec.md + CLAUDE + README + CHANGELOG
- `cli tool` → PRD + AGENTS + dev-workflow + commands.md + CLAUDE + README + CHANGELOG
- `desktop app` → PRD + AGENTS + dev-workflow + screens.md + (api-* if client-server) + CLAUDE + README + CHANGELOG

### Stack (open field)
**Q:** "What stack do you want to use? Anything goes."

Free text. The user describes: framework, DB, language, main libs.
Examples of valid answers:
- "Next.js 16 App Router + Supabase + Vercel"
- "Rails 7 + Supabase (for auth) + Postgres + Fly.io"
- "React Native + Expo + Supabase"
- "Python FastAPI + Postgres + Docker + Fly.io"
- "Elixir Phoenix + LiveView + Postgres"
- "Go + Chi router + sqlc + Postgres"

After the user answers, **the skill identifies the stack**:
1. If **exact match with an existing preset** (yii2-mysql, nextjs-supabase, etc.) → use the preset directly.
2. If **partial match** (e.g., user says "Next.js + Supabase" → preset already exists) → confirm: "I'll use the nextjs-supabase preset, ok?"
3. If **new stack** (e.g., Rails + Supabase, React Native) → notify: "I don't have a ready preset for that stack. I'll generate {STACK}-BEST-PRACTICES.md ad-hoc and save it as a new preset for reuse. Ok?"

**Quick shortcuts (only show if the user asks):** Next.js/Supabase, Yii2/MySQL.

### Hosting & observability (if not obvious from the stack)
**Q:** "Where does it run? Observability?"
- Free text. Defaults by stack:
  - Next.js → Vercel + Sentry
  - Yii2 → Docker / DigitalOcean + Sentry
  - Rails → Fly.io or Heroku + Sentry
  - React Native → App Store / Play Store + Sentry
  - Python → Fly.io / Railway + Sentry
- The user can override.

### Multi-tenant? (skip if project type = mobile client only, cli tool, desktop app without server)
**Q:** "Will multiple companies / customers use it with data isolation?"
- Options: **Yes, row-level** (`tenant_id` on every table, RLS in Postgres, TenantScopeTrait in Yii2) | **Yes, database-level** (1 DB per tenant) | **No, single-tenant** | Starts single, will become multi later

---

## Batch 3 - Auth & Roles

### Authentication method
**Q:** "How do users log in?"
- Options: **Email + password + optional MFA** (Recommended) | Magic Link (passwordless) | Corporate SSO (Google/Microsoft) | OAuth2 (third-party apps) | Supabase Auth built-in | Other

### Roles / permissions
**Q:** "Roles model?"
- Options: **Owner / Admin / Editor / Viewer** (Recommended) | **Admin / User** (simple) | **Custom roles** (will define later) | No roles (everyone equal)

---

## Batch 4 - Scope & Entities

### Core entities (MVP)
**Q:** "What are the 3-5 main entities of the system? (e.g., Lead, Campaign, Submission, Report)"
- Free text. Goes into the PRD Data Model.

### MVP v1.0 features
**Q:** "List 3-6 features that MUST be in v1.0. (What the system needs to do to be useful)"
- Free text, in bullets or commas.

### Explicit non-goals
**Q:** "List 3-5 things that v1.0 will NOT have. (What waits for v1.1 or never)"
- Free text. Important to avoid scope creep.

---

## Batch Hybrid - Only if the stack is hybrid (frontend stack ≠ backend stack)

Run this batch ONLY when the stack has different frontend and backend (e.g., "Next.js frontend + Python FastAPI backend", "React Native + Rails", "Vue + Go Chi").

### Repo layout
**Q:** "Will frontend and backend be in the same repo or separate?"
- Options: **Monorepo (1 repo with frontend/ and backend/ folders)** (Recommended) | Two separate repos | Frontend consumes a backend that already exists in another project

### Contract ownership
**Q:** "Who defines the API contract (endpoints, payloads, types)?"
- Options: **Backend-first** (backend defines, frontend consumes) (Recommended) | **Contract-first** (OpenAPI spec as source of truth, both implement) | **Frontend-driven** (frontend defines what it needs, backend implements)

→ This decides who owns auth, schema, error envelope, pagination. Default to backend-first unless the user picks another option. Goes into the "Architecture Split" section of the PRD.

---

## Batch 5 - Integrations

### Definite external integrations
**Q:** "Which APIs/services will the MVP use FOR SURE? (e.g., Stripe, OpenAI, Meta Ads)"
- Free text. Mark as "in scope".

### Possible integrations (maybe)
**Q:** "Which APIs/services MIGHT be added but you haven't decided yet?"
- Free text. Mark as "deferred / TBD" in the PRD.

---

## Wildcard question (if the briefing is too vague)

**Q:** "What is the concrete usage scenario? Describe one user doing one typical day-to-day action in this system."
- Free text. Helps extract entities, flows, and implicit UI.

---

## Execution rules

- **Batches of 2-4 questions at a time.** Do not dump 12 questions on the user.
- **Skip questions already answered in the briefing.** If the briefing already says "Next.js", do not ask the stack question.
- **Always mark the recommended option first** with "(Recommended)" in the label.
- **Always offer "Other"** so the user can customize (automatic in `AskUserQuestion`).
- **Do not ask fine details** in the interview (e.g., color, font, table name). Those become TBD in the PRD.
- **Maximum 3 batches** before moving to generation. If gaps remain after that, mark them as TBD.
