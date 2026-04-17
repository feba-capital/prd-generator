# Changelog

All notable changes to {{PROJECT_NAME}} are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [{{VERSION}}] — {{DATE}}

### Added
- Initial PRD and documentation structure created
- {{STACK_DESCRIPTION}} setup and configuration
- Project structure initialized{{#MULTITENANT_YES_NO}} with multi-tenant architecture{{/MULTITENANT_YES_NO}}
- {{AUTH_METHOD}} authentication framework
- Base API controllers and request/response envelopes
- Core models and database foundation
- API documentation and endpoint specifications
- Development workflow and testing setup
- CI/CD configuration (if applicable)

### Changed
- N/A (initial release)

### Fixed
- N/A (initial release)

### Deprecated
- N/A (initial release)

### Removed
- N/A (initial release)

### Security
- Encryption for sensitive fields (API keys, secrets)
- JWT token validation and rotation
{{#MULTITENANT_YES_NO}}
- Tenant isolation enforced at query level
{{/MULTITENANT_YES_NO}}

---

## Upcoming (v{{VERSION|increment}})

### Planned
- List features planned for next major version
- Additional integrations: {{INTEGRATIONS_DEFERRED|join:", "}}
- Performance optimizations
- Enhanced observability

### Deferred
{{#NON_GOALS}}
- {{. }}
{{/NON_GOALS}}

---

## Format Notes

- **Added** for new features
- **Changed** for changes in existing functionality
- **Fixed** for bug fixes
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Security** for security fixes or enhancements

Each release includes:
- Date in ISO 8601 format (YYYY-MM-DD)
- Semantic version following major.minor.patch
- Grouped changes by category

---

**Maintainer:** {{OWNER}}
**Repository:** {{PROJECT_SLUG}}
