# Stack Presets (shortcut library, NOT a closed list)

**Important:** This folder is a cache of stacks already used, not an exhaustive list. The PRD skill accepts ANY stack → if no preset exists here, the skill generates docs on-the-fly using general knowledge and saves the result here for future reuse.

Stack presets are templates for different technology stacks. Each preset contains best practices, coding standards, and configuration patterns specific to that stack.

When a PRD skill project selects a stack, the skill:
1. Checks if a matching preset exists here → copies it into the project's `/docs/`.
2. If partial match → copies and adapts (e.g., Next.js 14 preset used for Next.js 15 project).
3. If no match → generates a project-local ad-hoc preset first, copies it to the generated project, and only promotes it into this shared library after manual review and a skill sync.

This means the list below grows over time. Do not treat it as a limit on supported stacks.

---

## What's in a Stack Preset

Each preset lives in its own folder at `/stack-presets/{slug}/` and contains:

### Required Files

1. **PRESET.md** → Meta-information about the preset
   - Stack description and version info
   - Development workflow placeholders (commands)
   - Naming conventions
   - Default infrastructure
   - When to use / when not to use
   - Next steps after project init

2. **{STACK}-BEST-PRACTICES.md** → Coding standards and patterns
   - Project architecture
   - Code style guidelines
   - Common patterns (models, controllers, components)
   - Anti-patterns to avoid
   - Type safety / validation rules
   - Performance considerations
   - ~300-500 lines, intended to be a comprehensive style guide

### Optional Files

3. **{STACK}-TENANT-FILTERING.md** or **{STACK}-PATTERNS.md** → Multi-tenant specific patterns
   - Only required if the project has `multi_tenant: yes`
   - Database isolation, Row Level Security (RLS), access control patterns
   - Security checklist
   - ~200-300 lines

---

## Available Presets

### 1. yii2-mysql

**Slug:** `yii2-mysql`
**Tech:** PHP 8.2+, Yii2 Advanced Template, MySQL 8+, Docker, Dragonfly queue
**For:** Backend APIs, multi-tenant SaaS (established teams)

Files:
- `PRESET.md`
- `YII2-BEST-PRACTICES.md`
- `YII2-TENANT-FILTERING.md` (copied if multi-tenant=yes)

### 2. nextjs-supabase

**Slug:** `nextjs-supabase`
**Tech:** Next.js 14 (App Router), TypeScript, Supabase Postgres (RLS), Tailwind CSS, Vercel
**For:** Full-stack modern apps, multi-tenant SaaS (Fabio preference)

Files:
- `PRESET.md`
- `NEXTJS-BEST-PRACTICES.md`
- `SUPABASE-PATTERNS.md` (copied if multi_tenant=yes)

---

## Adding a New Preset

To add a new stack preset:

1. **Create the folder structure**
   ```
   skills/prd-generator/stack-presets/{new-slug}/
   ```

2. **Create PRESET.md** (required)
   ```
   # {Stack Name} Preset
   
   **Stack:** [technologies]
   **Use-case:** [when to use this]
   
   ## Arquivos fornecidos
   - NEXTJS-BEST-PRACTICES.md (or equivalent)
   - OPTIONAL-PATTERNS.md (if multi-tenant supported)
   
   ## Development Workflow Placeholders
   (table of commands: npm run test, npm run build, etc.)
   
   ## Naming Conventions
   (table of file patterns, variable naming, etc.)
   
   ## Default Infrastructure
   (table of hosting, database, auth, etc.)
   
   ## When to Use This Preset
   - ✓ Bulleted list of ideal use cases
   - ✗ Bulleted list of when NOT to use
   
   ## Next Steps After Project Init
   (numbered list of immediate setup tasks)
   ```

3. **Create {STACK}-BEST-PRACTICES.md** (required)
   - 300-500 lines of opinionated coding standards
   - 2-3 main sections (Architecture, Models/Components, Error Handling, etc.)
   - Concrete examples of GOOD vs BAD code
   - Type safety, validation, performance considerations
   - Anti-patterns to explicitly avoid

4. **Create {STACK}-TENANT-FILTERING.md or {STACK}-PATTERNS.md** (if applicable)
   - Only if the stack supports multi-tenant architecture
   - 200-300 lines covering data isolation, security, testing
   - Database schema patterns, queries, RLS/scoping examples
   - Security checklist for multi-tenant deployments

5. **Update `/skills/prd-generator/SKILL.md`**
   - Add the new preset to the stack options table
   - Include slug, description, best-for

6. **Test the preset**
   - Create a test project with the new stack
   - Verify files copy to `/docs/` correctly
   - Verify naming conventions and examples are clear

---

## Preset Design Principles

### 1. Opinion Over Neutrality
Presets are opinionated. They reflect a chosen way of working, not a menu of options. Example: "use PascalCase for components" not "you can use PascalCase or snake_case".

### 2. Practical Examples
Every best practice should have a code example. Bad examples help more than good ones alone.

### 3. Avoid Duplication
If a pattern is universal (e.g., "test everything"), mention it in PRESET.md, not in BEST-PRACTICES.md.

### 4. Document Anti-Patterns
Explicitly list what NOT to do. Many engineers learn better from negative examples.

### 5. Assume Intermediate Knowledge
Don't explain what functions are or what a database is. Assume the reader knows the language/framework at a mid-level.

### 6. Link to External Resources
Point to official docs for things that don't change frequently (e.g., "see Yii2 documentation for...").

---

## Verifying a New Preset

**Checklist before marking a preset as complete:**

- [ ] PRESET.md exists and is complete (meta, placeholders, next steps)
- [ ] {STACK}-BEST-PRACTICES.md exists and covers architecture, patterns, anti-patterns
- [ ] {STACK}-TENANT-FILTERING.md exists (if multi-tenant is supported)
- [ ] All filenames follow naming convention ({STACK} = yii2, nextjs, etc.)
- [ ] No typos or broken references between files
- [ ] Examples use consistent code style with the rest of the preset
- [ ] Checklist items are actionable (not vague)
- [ ] Preset added to `/skills/prd-generator/SKILL.md` with correct slug
- [ ] README.md updated (this file) to list the new preset

---

## Using Presets in the PRD Skill

When a user creates a project and selects a stack:

1. The skill reads the `PRESET.md` from `/stack-presets/{slug}/`
2. Copies BEST-PRACTICES.md to the project's `/docs/`
3. If `multi_tenant: yes`, also copies TENANT-FILTERING.md (or equivalent)
4. Adds a reference in the project's main README pointing to `/docs/{STACK}-BEST-PRACTICES.md`
5. Populates placeholders (build commands, naming conventions) into project config files

---

## Maintenance

**When to update a preset:**

- Stack version bumps (e.g., Yii2.2 → Yii2.3)
- New language features affect best practices (e.g., PHP 8.1 → PHP 8.2)
- Team discovers a new pattern that becomes standard
- Feedback from projects using the preset

**How to update:**

1. Edit the preset file directly
2. Use version comments if documenting a version-specific change: `<!-- Since Next.js 13.4 --> ... <!-- Until Next.js 15 -->`
3. Update PRESET.md if infrastructure or naming changes
4. Notify users of existing projects if the change is major

---

## Tips for Writing Good Presets

1. **Start with the PRESET.md** → Define the scope and use-cases first
2. **Add a real code example** → Even a toy example helps clarity
3. **Include a "When NOT to use" section** → Prevents misuse
4. **Keep file names consistent** → `YII2-BEST-PRACTICES.md` not `yii2-best-practices.md`
5. **Use tables for structured info** → Easier to scan than prose
6. **Link between files** → "See SUPABASE-PATTERNS.md for RLS setup"
7. **Test the preset** → Verify file copies and placeholders work

---

## Preset Folder Structure

```
skills/prd-generator/stack-presets/
├── README.md                           (this file)
├── yii2-mysql/
│   ├── PRESET.md
│   ├── YII2-BEST-PRACTICES.md
│   └── YII2-TENANT-FILTERING.md
├── nextjs-supabase/
│   ├── PRESET.md
│   ├── NEXTJS-BEST-PRACTICES.md
│   └── SUPABASE-PATTERNS.md
└── {future-stack}/
    ├── PRESET.md
    ├── {STACK}-BEST-PRACTICES.md
    └── {STACK}-PATTERNS.md (optional)
```

---

## Questions?

For stack preset questions or to add a new stack, see the PRD skill documentation.
