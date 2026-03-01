Generate a **complete onboarding document** for the codebase at: $ARGUMENTS

This is written by a principal architect for a junior engineer. It must be exhaustive and self-sufficient — covering architecture, design, data, API, behavior, operations, and development workflows. No pre-existing HLD or LLD is needed; derive everything from the codebase itself.

---

## Phase 1: Research (do ALL of this before writing a single word)

Read the following in order. Never skip a category.

**Structure**
- Full directory tree — every top-level folder and key files within each
- README if present (domain context, any existing documentation)

**Entry & Bootstrap**
- App entry points: `main.*`, `index.*`, `cmd/`, `app.*`, `server.*`
- Dependency wiring: DI container, factory functions, bootstrap sequence
- Dependency manifests: `go.mod`, `package.json`, `requirements.txt`, `Gemfile`, `pom.xml`

**Configuration**
- `.env.example`, `config.*`, `*.yaml`, `*.toml`, `*.ini` — every env var name and default
- The file that loads/validates config at startup

**Domain & Data**
- All database migration files in order — reconstruct the full schema history
- Core domain models/entities — the central data types the whole app revolves around
- Key interfaces, abstract classes, or type definitions

**API Surface**
- Router registration file(s) — all routes, middleware chain, HTTP method + path
- Handler files — request/response shapes, validation logic
- Middleware — auth, logging, rate limiting, error handling

**Business Logic**
- Service layer files — the 5-10 most-called services
- Most-imported utility packages

**Infrastructure**
- `Dockerfile`, `docker-compose.*` — local and production infrastructure
- `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile` — CI/CD pipeline stages
- `Makefile` or `package.json` scripts — all developer commands

**Tests**
- One representative unit test and one integration test — understand the patterns, mock setup, and assertion style
- Test configuration files

**Extract the real values**: actual env var names, actual file paths, actual function signatures, actual commands. Use `[placeholder]` only when the value genuinely cannot be determined from the code.

---

## Document Structure (22 sections)

### 1. What Is This System?
One paragraph: what it does, who uses it, what problem it solves. Then a domain glossary table (Term | Plain-English definition | Where it appears in code) covering every domain concept a new engineer will encounter.

### 2. Repo Structure
Annotated directory tree with every top-level directory and key files. For each entry: what it contains and when a developer touches it. End with a **"Start here"** callout — the 3–5 files to read first, in order, with one sentence explaining each.

### 3. System Context ← Excalidraw MCP hero diagram
`read_me` then `create_view`. Show: system boundary box, all actor types (human users, admin users, other systems), and every external dependency (databases, queues, third-party APIs, auth providers, CDNs). This is the one diagram a new engineer should look at first.

### 4. Architecture ← Mermaid `graph TB`
Internal component diagram with subgraphs by layer: Core/Blue, External/Green, Data stores/Yellow, Security/Red, Infra/Grey. Show all major services and connections. Follow with:
- **Component responsibilities table** (component | what it does | key files)
- **Communication patterns table** (from | to | protocol | sync or async | notes)

### 5. Key Files & Core Abstractions
**Key files table** — min 10 entries: file path | what it does | when you change it. Include: entry point, router, every middleware, core models, config loader, key utilities, test helpers.
For each snippet: show the actual code from the file with a `// file:line` comment.

**Core abstractions** — for each major interface/base class/pattern used in this codebase:
- What it is and why it exists
- Definition snippet (`// file:line`)
- Usage snippet (how to implement or call it)
- All existing implementations listed by file path

### 6. Data Model ← Mermaid ER diagram
Full ER with all tables/collections — every column with type and constraint. All FK relationships. Follow with:
- **Entity descriptions** — for each table: what it represents in the domain, when records are created/deleted, lifecycle notes, important field explanations (especially status enums, JSON blobs, soft-delete columns)
- **Index strategy table** (table | index name | columns | type | purpose)
- **Migration strategy** — which tool (`file`), how to create a new migration, how to run, how to roll back

### 7. Interface Reference
Determine the interface type from the codebase, then document accordingly:

**HTTP service** — discover all endpoints from the router file(s). For each: method, path, description, auth required, handler location (`file:line`). For every CRUD + complex operation: request schema with real field names and validation rules, response schema, error codes table (code | message | HTTP status | retryable), rate limits. Include: base URL, auth mechanism, pagination strategy with example shape.

**CLI tool** — document every command and flag: name, description, arguments, options, default values, example invocations. Discovered from `cmd/`, `cobra` commands, `argparse` setup, `click` decorators, etc.

**Library** — document every exported function/class: signature, parameters with types, return type, usage example (`file:line`). Discovered from public API surface (exported symbols, `__init__.py`, `index.ts`, etc.).

**Worker / batch processor** — document the job contract: input schema (queue message or cron trigger), processing steps, output / side effects, error handling and retry behavior. Discovered from queue consumer setup, job scheduler config.

### 8. System Behavior
Three sub-sections derived from reading the service and model layers:

**State Machine ← Mermaid `stateDiagram-v2`** — primary entity lifecycle. All valid states and transitions. Follow with transition rules table (from | to | trigger | guard condition).

**Event Design ← Mermaid flowchart** — producers → topics/queues → consumers → DLQ. Include a CloudEvents-style JSON schema example for the primary event type.

**Error Handling** — error taxonomy table (category | example | action). Retry config (read from code: max attempts, delays, backoff multiplier, retryable error types). Circuit breaker config if present. Fallback behavior table (scenario | fallback).

### 9. Data Flow Walkthroughs ← Mermaid sequence diagrams
The 2–3 most important user-facing operations. For each:
- **Narrative** — numbered steps in plain English, each step with `file:line` pointer
- **Sequence diagram** — every participant: client, middleware, handler, service, repository, DB, cache, queue
- **Failure paths** — what happens at each possible failure point (auth failure, validation error, DB down, queue down)

### 10. Non-Functional Requirements
Derive from code where possible (timeout values, pool sizes, retry limits, cache TTLs). Table: category | requirement | target | how measured. Cover: availability, P99 latency, throughput, scalability, data retention, RTO/RPO.

### 11. Infrastructure & Deployment ← Mermaid deployment diagram
- **Deployment diagram** — derive the actual topology from `Dockerfile`, `docker-compose.*`, CI/CD workflow files, and any Kubernetes/Terraform/CDK configs. Do not assume multi-AZ or specific components; show what exists.
- **CI/CD pipeline table** (stage | trigger | what it does | approx time) — read from workflow files
- **Environments table** (env | URL | DB | how to access)
- **How to deploy** — exact steps from workflow files or Makefile
- **How to roll back** — exact command or procedure

### 12. Monitoring & Observability
Key metrics table (metric | type: counter/gauge/histogram | alert threshold). Dashboards list with URLs if present in config. Log aggregation: where logs go, log format (structured JSON?), correlation ID strategy. SLI/SLO targets if defined in code or config.

### 13. Security
- **Auth flow** — method (JWT/OAuth2/API Key), validation location (`file:line`), RBAC roles and what each can do
- **Input validation** — table of validation rules per field (read from schema/validation files)
- **Encryption** — at rest (which fields, which algorithm, key management), in transit (TLS version), secrets management tool
- **OWASP checklist** — SQL injection, XSS, CSRF, rate limiting, security headers, dependency scanning — mark each present/absent/partial

### 14. Local Development Setup
**Prerequisites table** — tool | exact version (from `.nvmrc`, `go.mod`, `.python-version`, etc.) | check command | install command.

**Step-by-step** — every command in order, from a fresh machine to a running app. Number each step. Every command must be copy-pasteable and accurate. Include: clone, install deps, start infrastructure, configure env vars, run migrations, seed data, start server.

**Verify it's working** — exact command + expected output.

### 15. Daily Developer Workflows
For each workflow: exact commands AND the files to touch. Workflows to cover:
- Run all tests / single test file / test matching pattern / with coverage report
- Add a new API endpoint — step-by-step: router → handler → service → repository → test
- Add a database migration — create command, edit, run, verify, rollback
- Add a background job/worker
- Run linter / formatter / type checker
- Debug locally — start command, debugger port, VS Code config location
- Read application logs locally

### 16. Configuration & Environment Variables
Loaded by `[config file]`. The app [will / will not] start if a required var is missing.

Tables grouped by category — each row: variable name | required | default | description | example value:
- App config (port, log level, env name, etc.)
- Database (connection, pool sizes)
- External services (API keys, base URLs)
- Feature flags

### 17. Testing Guide
- **Structure** — annotated directory tree of the test folder
- **Run commands** — unit / integration / e2e separately + all together + coverage
- **Write a unit test** — complete real example from this codebase with describe/it/expect structure (`file:line`)
- **Write an integration test** — complete real example showing DB setup/teardown (`file:line`)
- **Mocking strategy** — external HTTP (tool + pattern), database (tool + pattern), time/clocks if applicable
- **Coverage targets** — where to check, what the current target is

### 18. Coding Conventions
Extracted from the actual codebase — not generic advice:
- File and folder naming (with examples from this repo)
- Function/variable naming rules (with examples)
- Error handling pattern — real snippet from this codebase (`file:line`)
- Logging pattern — real snippet (`file:line`)
- Where business logic lives vs infrastructure code — rule + example
- **What NOT to do** — min 5 anti-patterns, each with: pattern, why it's wrong, what to do instead, example from repo if present

### 19. Design Decisions

First, a summary table: # | Decision | Category | Chosen | Key Trade-off. Aim for 10–15 rows covering: language/runtime, framework, database type, ORM vs raw SQL, caching, auth mechanism, API style, API versioning, pagination, event/messaging system, error handling pattern, logging approach, config management, test strategy, containerization, monolith vs services.

Then, for each row, write a full ADR block:

**ADR-N: [Precise title — e.g., "PostgreSQL over MongoDB as primary data store"]**
- **Category:** Technology | Architecture | Data | API | Auth | Testing | Deployment | Cross-cutting
- **Context:** [What problem or constraint drove this decision?]
- **Options considered:** [At least 2 — one sentence each with their key characteristic]
- **Decision:** [What was chosen]
- **Rationale:** [Why — specific to this codebase, not generic]
- **Trade-offs accepted:** [What became harder; what flexibility was lost]
- **Consequences:** [Effect on dev experience, operations, future scalability]
- **Evidence:** `[file:line or library name from manifest]`

Infer decisions from: manifest files (every dependency is a decision), directory structure, config values, `deleted_at` columns (soft delete), UUID vs integer PKs, query param names (`cursor` vs `offset`), router file patterns, code comments with "Note:/Why:/Because:/HACK:" keywords.

### 20. Risks & Mitigations
Identify from reading the architecture: SPOFs, scaling bottlenecks, data loss scenarios, security gaps, operational risks. Table: # | Risk | Probability (H/M/L) | Impact (H/M/L) | Mitigation | Owner (team, not person).

### 21. Gotchas & FAQs
Min 10 real Q&As discovered from reading the code. Non-obvious behaviors, footguns, confusing patterns. Format:
**Q: [what a new engineer will inevitably wonder]**
A: [clear explanation + `file:line` pointer to the relevant code]

Categories to search for: implicit behaviors, global state, order-dependent init, magic timeout values, retry side effects, cache invalidation assumptions, environment-specific branching, hidden dependencies between modules.

### 22. First Week Checklist
- **Day 1** — setup + architecture reading list (link to sections above)
- **Day 2** — run tests, step through a flow in debugger, trivial change + PR
- **Day 3** — implement a small feature end-to-end
- **Contacts table** — area | owner | how to reach (fill from CODEOWNERS or leave as placeholder)

---

## Diagram Rules
- `%%{init: {'theme': 'neutral'}}%%` on all Mermaid diagrams
- `<!-- diagram-tool: mermaid|excalidraw -->` above each diagram
- Color coding: Blue (#4A90D9)=core, Green (#7CB342)=external, Yellow (#FDD835)=data, Red (#E53935)=security, Grey (#9E9E9E)=infra
- Max 2 Excalidraw diagrams total — the system context hero, plus one more only if genuinely needed

## Output
- Create `docs/` if it doesn't exist
- Save to `docs/onboarding.md`
- **If the document is too long to complete in one response:** generate §1–11 first (architecture, data, interfaces, behavior, infra), then explicitly say "Continuing with §12–22…" and proceed. Never silently truncate.
- After writing, print a one-line summary per section confirming it was completed
