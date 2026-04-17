# {{PROJECT_NAME}}

![Status](https://img.shields.io/badge/status-active-success)
![Stack](https://img.shields.io/badge/stack-{{STACK_SLUG|upper}}-blue)
![Version](https://img.shields.io/badge/version-{{VERSION}}-informational)

{{PROJECT_TAGLINE}}

---

## Features

- {{MVP_GOALS|first}}
- {{MVP_GOALS|second}}
- {{MVP_GOALS|third}}
- {{#MULTITENANT_YES_NO}}Multi-tenant architecture with row-level security{{/MULTITENANT_YES_NO}}
- {{AUTH_METHOD}} authentication{{#MULTITENANT_YES_NO}} with MFA support{{/MULTITENANT_YES_NO}}
- Fully documented REST API

---

## Quick Start

### Prerequisites
- {{STACK_DESCRIPTION|extract:runtime}} (version X.X+)
- {{STACK_DESCRIPTION|extract:database}} (version X.X+)
- Docker (optional)

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd {{PROJECT_SLUG}}
   ```

2. **Install dependencies**
   ```bash
   # Install based on stack
   npm install
   # or
   composer install
   # or
   pip install -r requirements.txt
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with local settings
   ```

4. **Initialize database**
   ```bash
   # Apply migrations
   npm run migrate
   # or
   php yii migrate
   # or
   python manage.py migrate
   ```

5. **Start development server**
   ```bash
   npm run dev
   # or
   php -S localhost:8000
   # or
   python manage.py runserver
   ```

   API available at `http://localhost:8000/api/v{{VERSION}}/`

### Docker Setup

```bash
docker-compose up -d
docker exec -it {{PROJECT_SLUG}}-app bash
```

---

## Project Structure

```
{{PROJECT_SLUG}}/
├── src/
│   ├── api/              # HTTP API
│   │   ├── controllers/  # REST controllers
│   │   ├── config/       # API config
│   │   └── tests/        # API tests
│   ├── common/           # Shared code
│   │   ├── models/       # Data models
│   │   ├── jobs/         # Queue jobs
│   │   └── components/   # Shared utilities
│   └── console/          # CLI commands
│       ├── migrations/   # Database migrations
│       └── controllers/  # Console commands
├── docs/                 # Documentation
│   ├── api-docs.md
│   ├── api-endpoints.md
│   ├── api-models.md
│   └── AGENTS.md
├── docker-compose.yml    # Docker services
├── .env.example          # Environment template
└── README.md             # This file
```

---

## Development

### Running Tests

```bash
npm test
# or
composer tests
# or
python -m pytest
```

### Code Quality

```bash
# Type checking
npm run type-check
# or
composer phpstan

# Linting
npm run lint
# or
composer phpcs

# Auto-fix
npm run lint:fix
# or
composer phpcbf
```

### Database Migrations

```bash
# Create migration
npm run migrate:create <name>
# or
php yii migrate/create <name>

# Apply migrations
npm run migrate
# or
php yii migrate

# Rollback
npm run migrate:down
# or
php yii migrate/down 1
```

---

## API Documentation

Complete API documentation available in `/docs/`:

- **[API Overview](docs/api-docs.md)** → Architecture, auth flow, conventions
- **[Endpoints](docs/api-endpoints.md)** → Detailed endpoint specs with request/response examples
- **[Models](docs/api-models.md)** → Data model reference
- **[Controllers](docs/api-controllers.md)** → Implementation patterns

Quick reference:
- Base URL: `/api/v{{VERSION}}/`
- Auth: {{AUTH_METHOD}}
- All responses: standard envelope format (success/error)

---

## Contributing

1. Create a feature branch: `git checkout -b feature/<name>`
2. Make changes and follow coding standards (see [AGENTS.md](docs/AGENTS.md))
3. Run tests and checks: `npm test && npm run check`
4. Commit with descriptive message: `git commit -m "feat: description"`
5. Push and open a pull request

---

## Deployment

### Hosting: {{HOSTING}}

### Environment Variables

Required in `.env`:
- `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`
- `JWT_SECRET` — secret key for signing tokens
- `ENCRYPTION_KEY` — for encrypting sensitive fields

Optional:
- `LOG_LEVEL` — default: info
- `OBSERVABILITY_ENDPOINT` — {{OBSERVABILITY}}

### Production Checklist

- [ ] All tests passing
- [ ] Environment variables configured
- [ ] Database migrations applied
- [ ] TLS/SSL configured
- [ ] Backups enabled
- [ ] Monitoring set up

---

## Troubleshooting

### Database connection error
- Verify `DB_*` environment variables
- Check MySQL/Postgres is running: `docker-compose ps`
- Run migrations: `npm run migrate`

### Auth/Token errors
- Verify `JWT_SECRET` is set in `.env`
- Check token hasn't expired (15 min TTL)
- Try refreshing token: `POST /api/v{{VERSION}}/auth/refresh`

### Test failures
- Ensure migrations applied in test DB: `npm test:migrate`
- Check test config in `{{STACK_SLUG}}` test suite files
- Review test output for specific errors

---

## Support & Issues

{{#PROJECT_NAME}}
- Documentation: See `/docs/` directory
- Issues: Open a GitHub issue
- Slack: {{#OWNER|downcase}}#{{PROJECT_SLUG}}
{{/PROJECT_NAME}}

---

## License

Internal project. Proprietary.

---

**Last updated:** {{DATE}}
**Current version:** v{{VERSION}}
**Maintainer:** {{OWNER}}
