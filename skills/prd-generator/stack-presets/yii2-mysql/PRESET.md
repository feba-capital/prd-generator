# Yii2 + MySQL Preset

**Stack:** PHP 8.2+, Yii2 Advanced Template, MySQL 8+, Docker, Dragonfly queue
**Use-case:** Backend APIs similar to WiserContent / established web services (multi-tenant SaaS)

---

## Arquivos fornecidos

- **YII2-BEST-PRACTICES.md** → Coding standards, Yii2 patterns, SOLID/DRY/KISS, type safety, error handling
- **YII2-TENANT-FILTERING.md** → Multi-tenant scoping rules (use only if project has multi_tenant=yes)

---

## Development Workflow Placeholders

| Task | Command |
|------|---------|
| Run tests | `composer tests` (Codeception + unit/api tests) |
| Static analysis | `composer phpstan` (PHPStan Level 8) |
| Code style check | `composer phpcs` (PSR-2 + custom rules) |
| Fix style | `composer phpcbf` |
| Run migrations | `php yii migrate` |
| Dev server | `docker compose up -d` |
| Logs | `docker compose logs -f api` |
| Console command | `php yii {command}` |

---

## Naming Conventions

| Item | Pattern | Example |
|------|---------|---------|
| Migration | `m{YYMMDD}_{HHMMSS}_{name}.php` | `m250414_093045_create_posts_table.php` |
| Model | `common/models/{Name}.php` | `common/models/Post.php` |
| Controller | `api/controllers/v1/{Name}Controller.php` | `api/controllers/v1/PostController.php` |
| Service/Job | `common/{type}/{Name}.php` | `common/jobs/PublishJob.php` |
| Behavior | `common/behaviors/{Name}Behavior.php` | `common/behaviors/AuditBehavior.php` |
| Table name | `{{%table_name}}` (snake_case) | `{{%blog_posts}}` |
| Column name | snake_case | `created_at`, `tenant_id` |
| Constant | UPPER_SNAKE_CASE | `STATUS_ACTIVE`, `MAX_RETRIES` |

---

## Default Infrastructure

| Component | Standard |
|-----------|----------|
| Hosting | Docker + DigitalOcean / AWS EC2 / any Kubernetes-compatible host |
| Queue system | Dragonfly (Redis-compatible, simpler than full Redis) |
| Database | MySQL 8+ with InnoDB, utf8mb4 collation |
| Cache | Dragonfly (same as queue) |
| Logging | Syslog / file-based (Yii2 default logger) |
| Deployment | Docker image build → push to registry → deploy |
| Auth | JWT (Bearer tokens) in Authorization header |

---

## Key Files Structure

```
src/
├── api/
│   ├── web/
│   │   └── index.php          (API entrypoint)
│   ├── controllers/
│   │   └── v1/                (v1 API controllers)
│   ├── components/
│   │   └── Controller.php      (base controller with buildSuccessResponse, etc.)
│   └── config/
│       └── main.php           (API app config)
├── console/
│   ├── controllers/           (console commands, queue workers)
│   ├── config/
│   │   └── main.php
│   └── migrations/            (database migrations)
├── common/
│   ├── models/                (ActiveRecord models, one per table)
│   ├── components/
│   │   └── TenantScopeTrait.php (multi-tenant isolation)
│   ├── services/              (business logic services)
│   ├── jobs/                  (queue job classes)
│   ├── behaviors/             (Yii2 behaviors)
│   └── config/
│       ├── main.php           (shared config)
│       └── bootstrap.php
└── tests/
    ├── api/                   (functional API tests)
    ├── unit/                  (unit tests)
    └── fixtures/              (test data)
```

---

## Performance Considerations

- **Eager load** relations with `.with()` to avoid N+1 queries
- **Index tenant_id** on every tenant-owned table
- **Use composite indexes** for (tenant_id, status), (tenant_id, slug), etc.
- **Cursor-based pagination** instead of offset-based for large datasets
- **Archive instead of delete** → soft deletes via status column
- **Queue long-running tasks** via Dragonfly jobs, don't do them in HTTP requests

---

## Security Baseline

- **TenantScopeTrait on all models** → automatic `tenant_id` filtering
- **JWT extraction** → get tenant_id from token, never from request body
- **Type safety** → PHPStan Level 8 catches type errors at build time
- **Never cache sensitive data** without tenant key (e.g., `cache:post:{tenant_id}:{post_id}`)
- **Encrypt secrets** → API keys, webhook signatures, stored in ENV + AES-256 in DB
- **Error messages** → use 404 consistently, don't leak record existence across tenants

---

## When to Use This Preset

✓ Multi-tenant SaaS platforms (B2B)
✓ REST APIs handling complex domain logic
✓ Brownfield projects (existing Yii2 codebases)
✓ Teams familiar with PHP / Yii2 ecosystem
✓ Projects needing mature, battle-tested patterns

✗ Not ideal for simple CRUD-only APIs
✗ Not ideal if team prefers modern JavaScript/TypeScript stacks
✗ Not ideal for real-time / WebSocket-heavy applications

---

## Learning Resources

- [Yii2 Guide](https://www.yiiframework.com/doc/guide/2.0/en)
- [PSR-2 Coding Standard](https://www.php-fig.org/psr/psr-2/)
- [PHPStan](https://phpstan.org/) → static analysis
- Docker best practices for PHP applications

---

## Next Steps After Project Init

1. Set up `src/common/components/TenantScopeTrait.php` (copy from YII2-TENANT-FILTERING.md)
2. Create base `api/components/Controller.php` with response builders
3. Set up migrations folder structure and first migration (create users table)
4. Configure Docker Compose with API service + MySQL + Dragonfly
5. Set up GitHub Actions CI → phpstan, phpcs, tests
6. Configure local `.env.example` with required variables
7. Document API endpoints in @docs/api-endpoints.md as you build
