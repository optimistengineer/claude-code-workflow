Generate a **Design Decisions & Trade-offs** document for the codebase at: $ARGUMENTS

If no target is specified, ask: "Which codebase should I analyze? Provide a path or repo URL."

This document captures every significant architectural and technical decision made in this codebase — the "why" behind the choices. Everything is inferred from reading the code, not assumed.

---

## Phase 1: Research (read ALL of this before writing anything)

Work through each category. Evidence is in the files listed.

**Stack**
- Dependency manifests: `go.mod`, `package.json`, `requirements.txt`, `Gemfile`, `pom.xml`, `Cargo.toml` — every dependency is a decision
- Runtime version pins: `.nvmrc`, `.python-version`, `.tool-versions`, `go.mod`, `Dockerfile FROM`

**Architecture shape**
- Top-level directory structure — layered? hexagonal? feature-based? monorepo?
- Number of services — monolith or microservices? Look for multiple `main.*` / `cmd/` / service directories
- How services communicate — REST calls, gRPC, events, shared DB?

**Data layer**
- Database type and vendor — driver dependency + migration files
- ORM or raw SQL — look for ORM library vs raw query strings
- Migration tool — folder name + files inside
- Caching — Redis/Memcached dependency, TTL values in config
- Primary key type — UUID vs integer (look at migration files)
- Soft delete vs hard delete — `deleted_at` column in migrations?

**API surface**
- REST vs GraphQL vs gRPC — router files, `.graphql` / `.proto` files
- Versioning strategy — `/v1/` in routes, header-based, URL-based
- Pagination type — `cursor`, `offset`, `page` in query params
- Auth mechanism — JWT library, session middleware, OAuth library, API key pattern

**Cross-cutting**
- Error handling — custom error types file, error middleware, how errors are wrapped and mapped to HTTP codes
- Logging library and format — import + structured log calls vs `console.log` / `fmt.Println`
- Config management — `.env` loading library, config struct, validation on startup
- Test strategy — test framework, `testcontainers` vs mocks, test-to-code file ratio

**Deployment**
- Containerization — `Dockerfile`, `docker-compose.*`
- Orchestration — Kubernetes manifests, ECS task definitions, Fly.io config
- CI/CD tool — `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`

**README and comments**
- Any existing ADRs or architectural notes in README
- Code comments starting with: `// Note:`, `// Why:`, `// Because:`, `// HACK:`, `// TODO:`, `// NB:` — these document decisions
- Git commit messages if accessible

**Extract evidence**: actual library names, actual config values, actual file paths. Use `[unknown]` only when genuinely undetectable.

---

## Document Structure

### Part 1 — Summary Table

| # | Decision | Category | Chosen | Key Trade-off |
|---|----------|----------|--------|---------------|
[One row per decision — aim for 10–15]

---

### Part 2 — Full ADRs

For each row in the summary table, write a full ADR block:

---

**ADR-N: [Precise title — e.g., "PostgreSQL over MongoDB as primary data store"]**

**Category:** Technology | Architecture | Data | API | Auth | Testing | Deployment | Cross-cutting

**Context**
[What problem or need drove this decision? What constraints existed at the time — team size, existing infra, data shape, scale requirements?]

**Options Considered**
- **[Option A]** — [one sentence: what it is + key characteristic relevant to this decision]
- **[Option B]** — [one sentence]
- **[Option C]** (if applicable)

**Decision**
[Option X was chosen.]

**Rationale**
[Why this option over the others — be specific to this codebase, not generic. Reference evidence from the code where possible.]

**Trade-offs Accepted**
- [What became harder or impossible]
- [What you give up]
- [What future flexibility is reduced]

**Consequences**
- Developer experience: [effect]
- Operations: [effect]
- Future scalability or flexibility: [effect]

Evidence: `[file:line or dependency name]`

---

[repeat for each decision]

## Categories Checklist

Cover every category that applies. Skip only if there is genuinely no evidence of a decision:

| Category | What to look for | ADR needed? |
|----------|-----------------|-------------|
| Language / Runtime | `Dockerfile FROM`, version pin files | If non-obvious choice |
| Framework | Top-level framework dependency | Always |
| Database type | Driver + migration files | Always if DB exists |
| ORM vs raw SQL | ORM library vs raw queries | If DB exists |
| Caching strategy | Cache library, TTL values, what's cached | If cache exists |
| Primary key type | Migration files (`uuid` vs `serial`) | If non-default |
| Soft vs hard delete | `deleted_at` column | If soft delete used |
| Auth mechanism | Auth library, middleware file | Always if auth exists |
| API style | Router files, `.proto`, `.graphql` | Always if external API |
| API versioning | Route prefixes, header names | If versioned |
| Pagination strategy | Query param names in handlers | If list endpoints exist |
| Event / messaging | Queue library, broker config | If async messaging exists |
| Error handling pattern | Custom error types, middleware | Always |
| Logging approach | Log library, structured vs unstructured | Always |
| Config management | Config loading library, validation | Always |
| Test strategy | Test framework, mock approach | Always |
| Containerization | Dockerfile, docker-compose | If present |
| Monolith vs services | Directory structure, inter-service calls | Always |

## Output
- Create `docs/` if it doesn't exist
- Save to `docs/design-decisions.md`
- After saving, print: "Generated [N] ADRs across [M] categories — saved to docs/design-decisions.md"
