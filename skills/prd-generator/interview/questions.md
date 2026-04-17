# Interview Question Bank

Banco de perguntas por campo. Use quando o briefing tem ✗ ou ?. Formule via `AskUserQuestion` tool, em batches de 2-4.

---

## Batch 1 — Fundação (se faltar qualquer um, pergunte juntos)

### Nome do projeto
**Q:** "Qual o nome oficial desse projeto?"
- Livre-text (sem opções). Precisa do slug derivável.

### Público-alvo principal
**Q:** "Quem é o principal usuário desse produto?"
- Opções: CEOs/Founders (interno FEBA) | Funcionários das empresas FEBA | Clientes finais B2B | Clientes finais B2C | Desenvolvedores (devtools) | Other

### One-liner / problema central
**Q:** "Em 1 frase: qual o problema principal que esse projeto resolve?"
- Livre-text. Vai pro campo Tagline do PRD.

---

## Batch 2 — Project Type & Stack

### Project type
**Q:** "Que tipo de projeto é esse?"
- Opções: **Fullstack web app** (frontend + backend + DB) | **Backend API only** (sem UI própria, serve APIs) | **Mobile app** (iOS/Android client, com ou sem backend próprio) | **Browser extension** | **CLI tool / script** | **Desktop app** | Other

→ Isso decide quais templates rodam:
- `fullstack web app` → PRD + AGENTS + dev-workflow + api-docs/endpoints/models/controllers + CLAUDE + README + CHANGELOG
- `backend api only` → igual fullstack, sem docs de UI
- `mobile app` → PRD + AGENTS + dev-workflow + screens.md + state-model.md + (api-* se tiver backend proprio) + CLAUDE + README + CHANGELOG
- `browser extension` → PRD + AGENTS + dev-workflow + manifest-spec.md + CLAUDE + README + CHANGELOG
- `cli tool` → PRD + AGENTS + dev-workflow + commands.md + CLAUDE + README + CHANGELOG
- `desktop app` → PRD + AGENTS + dev-workflow + screens.md + (api-* se cliente-servidor) + CLAUDE + README + CHANGELOG

### Stack (campo aberto)
**Q:** "Qual stack você quer usar? Pode ser qualquer coisa."

Texto livre. Fabio descreve: framework, DB, linguagem, libs principais.
Exemplos de respostas válidas:
- "Next.js 14 App Router + Supabase + Vercel"
- "Rails 7 + Supabase (pra auth) + Postgres + Fly.io"
- "React Native + Expo + Supabase"
- "Python FastAPI + Postgres + Docker + Fly.io"
- "Elixir Phoenix + LiveView + Postgres"
- "Go + Chi router + sqlc + Postgres"

Depois que Fabio responder, **o skill identifica o stack**:
1. Se **match exato com um preset existente** (yii2-mysql, nextjs-supabase, etc.) → usa o preset direto.
2. Se **match parcial** (ex: Fabio diz "Next.js + Supabase" → já tem preset) → confirma: "vou usar o preset nextjs-supabase, ok?"
3. Se **stack novo** (ex: Rails + Supabase, React Native) → avisa: "não tenho preset pronto pra esse stack, vou gerar os docs {STACK}-BEST-PRACTICES.md ad-hoc e salvar como preset novo pra reutilizar. Ok?"

**Atalhos rápidos (só mostrar se Fabio pedir):** Next.js/Supabase, Yii2/MySQL.

### Hosting & observability (se não óbvio pelo stack)
**Q:** "Onde roda? Observability?"
- Livre-text. Defaults por stack:
  - Next.js → Vercel + Sentry
  - Yii2 → Docker / DigitalOcean + Sentry
  - Rails → Fly.io ou Heroku + Sentry
  - React Native → App Store / Play Store + Sentry
  - Python → Fly.io / Railway + Sentry
- Fabio pode sobrescrever.

### Multi-tenant? (skip se project type = mobile client only, cli tool, desktop app sem servidor)
**Q:** "Vai ter múltiplas empresas / clientes usando, com isolamento de dados?"
- Opções: **Sim, row-level** (`tenant_id` em toda tabela, RLS no Postgres, TenantScopeTrait no Yii2) | **Sim, database-level** (1 DB por tenant) | **Não, single-tenant** | Começa single, vou virar multi depois

---

## Batch 3 — Auth & Roles

### Método de autenticação
**Q:** "Como usuários fazem login?"
- Opções: **Email + senha + MFA opcional** (Recommended) | Magic Link (passwordless) | SSO corporativo (Google/Microsoft) | OAuth2 (apps de terceiros) | Supabase Auth built-in | Other

### Roles / permissões
**Q:** "Modelo de roles?"
- Opções: **Owner / Admin / Editor / Viewer** (Recommended, mesmo do WiserContent) | **Admin / User** (simples) | **Custom roles** (vou definir depois) | Não tem roles (todos iguais)

---

## Batch 4 — Escopo & Entidades

### Entidades core (MVP)
**Q:** "Quais são as 3-5 entidades principais do sistema? (ex: Lead, Campaign, Submission, Report)"
- Livre-text. Isso vai pro Data Model do PRD.

### Features MVP v1.0
**Q:** "Liste 3-6 features que PRECISAM estar no v1.0. (O que o sistema tem que fazer pra ser útil)"
- Livre-text, em bullets ou vírgulas.

### Non-goals explícitos
**Q:** "Liste 3-5 coisas que v1.0 NÃO vai ter. (O que fica pra v1.1 ou nunca)"
- Livre-text. Importante pra evitar scope creep.

---

## Batch Hybrid — Só se stack é híbrido (frontend stack ≠ backend stack)

Rode esse batch APENAS quando o stack tem frontend e backend diferentes (ex: "Next.js frontend + Python FastAPI backend", "React Native + Rails", "Vue + Go Chi").

### Repo layout
**Q:** "Frontend e backend vão ficar no mesmo repo ou separados?"
- Opções: **Monorepo (1 repo com pastas frontend/ e backend/)** (Recommended) | Dois repos separados | Frontend consome backend já existente em outro projeto

### Contract ownership
**Q:** "Quem define o contrato da API (endpoints, payloads, tipos)?"
- Opções: **Backend-first** (backend define, frontend consome) (Recommended) | **Contract-first** (OpenAPI spec como fonte de verdade, ambos implementam) | **Frontend-driven** (frontend define o que precisa, backend implementa)

→ Isso decide quem manda em auth, schema, error envelope, pagination. Sempre backend-first a menos que Fabio escolha outra opção. Vai pra seção "Architecture Split" do PRD.

---

## Batch 5 — Integrações

### Integrações externas de CERTEZA
**Q:** "Quais APIs/serviços externos o MVP JÁ vai usar? (ex: Stripe, OpenAI, Meta Ads)"
- Livre-text. Marcar como "in scope".

### Integrações POSSÍVEIS (talvez)
**Q:** "Quais APIs/serviços PODEM entrar mas você ainda não decidiu?"
- Livre-text. Marcar como "deferred / TBD" no PRD.

---

## Pergunta-curinga (se o briefing é vago demais)

**Q:** "Qual o cenário concreto de uso? Descreva 1 usuário fazendo 1 ação típica do dia-a-dia nesse sistema."
- Livre-text. Isso ajuda a extrair entities, flows, e UI implícita.

---

## Rules de execução

- **Batches de 2-4 perguntas por vez.** Não jogue 12 perguntas no Fabio.
- **Pular perguntas já respondidas no briefing.** Se briefing já diz "Next.js", não pergunte stack.
- **Sempre marcar opção recomendada primeiro** com "(Recommended)" no label.
- **Sempre oferecer "Other"** pra ele customizar (automático no AskUserQuestion).
- **Não perguntar detalhes finos** na entrevista (ex: cor, fonte, nome de tabela). Isso vira TBD no PRD.
- **Máximo 3 batches** antes de partir pra geração. Se depois disso ainda tem buraco, marque TBD.
