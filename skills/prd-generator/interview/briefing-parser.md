# Briefing Parser

Como ler o briefing livre do Fabio e montar o checklist de 12 campos.

## Os 12 campos-chave

| # | Campo | O que estar procurando no briefing |
|---|---|---|
| 1 | **Nome do projeto** | Nome literal ("WiserLeads v2", "SlideGen", "ContentOps"). Se não tiver, derive do problema. |
| 2 | **Problema / objetivo** | "Por que existe?" → frase que justifica o projeto. |
| 3 | **Público / usuários** | Quem usa. CEOs? Devs internos? Clientes finais? B2B ou B2C? |
| 4 | **Stack técnico** | Framework mencionado (Next.js, Yii2, Rails, etc.). DB se mencionado. Hosting se mencionado. |
| 5 | **Autenticação** | Login via email/senha? Social? SSO? MFA? Magic link? Pode estar implícito (se é B2B interno, provavelmente SSO). |
| 6 | **Multi-tenant** | Palavras-chave: "tenant", "multi-empresa", "cada cliente tem seu", "isolamento", "whitelabel", "portfolio". |
| 7 | **Roles / permissões** | Palavras-chave: "admin", "user", "role", "permissão", "owner", "viewer". |
| 8 | **Entidades principais** | Substantivos que aparecem repetidos: "lead", "post", "slide deck", "campaign", "form submission". |
| 9 | **Integrações externas** | APIs mencionadas (Stripe, OpenAI, Supabase, Meta Ads, etc.). Separe "de certeza" vs "pode precisar". |
| 10 | **Escopo MVP** | "Pra começar", "v1", "MVP", "primeiro milestone". |
| 11 | **Non-goals** | "Não vou fazer", "depois", "não inclui", "fora de escopo". |
| 12 | **Deploy / infra** | Hosting mencionado (Vercel, AWS, Docker, bare metal). Observabilidade se mencionada. |

## Como marcar o checklist

Pra cada campo, classifique:

- **✓ Completo** → briefing responde claramente, não precisa perguntar
- **? Parcial** → tem pista mas falta detalhe, precisa UMA follow-up
- **✗ Ausente** → não mencionado, precisa pergunta completa

## Heurísticas

### Defaults razoáveis (pra não encher de perguntas)

- Owner do PRD: "Fabio / FEBA Capital"
- Hosting se Next.js: Vercel
- Hosting se Yii2/PHP: Docker + DigitalOcean/AWS
- DB se Next.js: Supabase Postgres
- DB se Yii2: MySQL
- Versioning: sempre v1.0 pro PRD inicial
- Observabilidade: Sentry (todos os projetos Feba usam `logger.febacapital.com`)
- Commit convention: Conventional Commits (feat/fix/refactor/etc.)

### Quando multi-tenant é o DEFAULT

Se o projeto é um SaaS interno onde múltiplas empresas da FEBA vão usar (Consolide, MySide, Azeen, etc.), multi-tenant é praticamente certo. Confirme mesmo assim, mas assuma "yes" como default.

Se o projeto é uma ferramenta pessoal do Fabio (brainstorm tool, dashboard pessoal), multi-tenant é "no".

### Quando perguntar mais vs assumir

- **Pergunte sempre:** multi-tenant (s/n), auth method, stack (se 2+ stacks plausíveis), scope MVP, non-goals.
- **Assuma com default:** hosting, DB, observabilidade, commit convention, versioning.
- **Sempre confirme antes de gerar:** o resumo completo no Step 4.

## Output esperado

Depois de parsear, monte um checklist mental no formato:

```
[✓] Nome: WiserLeads v2
[✓] Problema: modernizar o legacy WiserLeads para Next.js + Supabase
[✗] Público: (não dito) → perguntar
[?] Stack: "Next.js" mencionado, mas e backend? DB? → perguntar
[✗] Auth: (não dito) → perguntar
[✗] Multi-tenant: (não dito) → perguntar
...
```

Depois use esse checklist pra montar o batch de perguntas da entrevista.
