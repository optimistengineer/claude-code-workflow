# Onboarding Guide: [System Name]

**Written by:** [Principal Architect]
**Last updated:** [Date]
**Repo:** [URL]

> This document is exhaustive by design. A new engineer should be able to understand, run, and contribute to this system using only this document. If something is missing, that's a bug — open a PR to fix it.

---

## Table of Contents

1. [What Is This System?](#1-what-is-this-system)
2. [Repo Structure](#2-repo-structure)
3. [System Context](#3-system-context)
4. [Architecture](#4-architecture)
5. [Key Files & Core Abstractions](#5-key-files--core-abstractions)
6. [Data Model](#6-data-model)
7. [API Reference](#7-api-reference)
8. [System Behavior](#8-system-behavior)
9. [Data Flow Walkthroughs](#9-data-flow-walkthroughs)
10. [Non-Functional Requirements](#10-non-functional-requirements)
11. [Infrastructure & Deployment](#11-infrastructure--deployment)
12. [Monitoring & Observability](#12-monitoring--observability)
13. [Security](#13-security)
14. [Local Development Setup](#14-local-development-setup)
15. [Daily Developer Workflows](#15-daily-developer-workflows)
16. [Configuration & Environment Variables](#16-configuration--environment-variables)
17. [Testing Guide](#17-testing-guide)
18. [Coding Conventions](#18-coding-conventions)
19. [Design Decisions](#19-design-decisions)
20. [Risks & Mitigations](#20-risks--mitigations)
21. [Gotchas & FAQs](#21-gotchas--faqs)
22. [First Week Checklist](#22-first-week-checklist)

---

## 1. What Is This System?

[One paragraph: what it does, who uses it, what problem it solves.]

### Domain Glossary

| Term | Definition | Where it appears in code |
|------|-----------|--------------------------|
| [Term] | [Plain-English definition] | `[file path]` |
| [Term] | [Plain-English definition] | `[file path]` |

---

## 2. Repo Structure

```
[repo-name]/
├── [dir]/          # [what's in here — when devs touch it]
│   ├── [subdir]/   # [purpose]
│   └── [file]      # [purpose]
├── [dir]/          # [purpose]
├── Makefile        # All dev commands — start here
├── docker-compose.yaml  # Local infrastructure
└── .env.example    # All required environment variables
```

### Start Here
Read these files first, in this order:
1. `[entry point]` — boots the app, shows how everything is wired
2. `[router file]` — shows the full API surface
3. `[core model]` — the central entity everything revolves around
4. `[config file]` — shows every required environment variable

---

## 3. System Context

<!-- diagram-tool: excalidraw -->
> **[Excalidraw hero diagram]** — Full system context: system boundary, all actor types, and every external dependency.

---

## 4. Architecture

<!-- diagram-tool: mermaid -->
```mermaid
%%{init: {'theme': 'neutral'}}%%
graph TB
    subgraph Core["Core Services"]
        API[API / Handler Layer]
        SVC[Service / Business Logic]
        REPO[Repository / Data Access]
    end

    subgraph Data["Data Stores"]
        DB[(Primary DB)]
        CACHE[(Cache)]
    end

    subgraph External["External Systems"]
        QUEUE[Message Queue]
        AUTH[Auth Provider]
        EXT[Third-party API]
    end

    Client --> API
    API --> AUTH
    API --> SVC
    SVC --> REPO
    REPO --> DB
    SVC --> CACHE
    SVC --> QUEUE

    style Core fill:#E3F2FD,stroke:#4A90D9
    style Data fill:#FFF9C4,stroke:#FDD835
    style External fill:#E8F5E9,stroke:#7CB342
```

### Component Responsibilities

| Component | What it does | Key files |
|-----------|-------------|-----------|
| [Component] | [Responsibility] | `[file]` |

### Communication Patterns

| From | To | Protocol | Sync/Async | Notes |
|------|-----|----------|-----------|-------|
| [A] | [B] | REST | Sync | [note] |
| [A] | [Queue] | AMQP | Async | [note] |

---

## 5. Key Files & Core Abstractions

### Key Files

| File | What it does | When you'll change it |
|------|-------------|----------------------|
| `[entry point]` | App bootstrap, dependency wiring | Almost never |
| `[router]` | Route registration | Adding an endpoint |
| `[auth middleware]` | JWT validation, attaches user to context | Changing auth logic |
| `[error middleware]` | Global error handler, response shaping | Changing error format |
| `[core model]` | Central domain entity | Schema changes |
| `[config loader]` | Loads + validates env vars at startup | Adding new config |
| `[migrations dir]` | DB schema history | Schema changes |
| `[test helper]` | DB setup/teardown for tests | Changing test infra |

### Entry Point

```[language]
// [entry-point file]:[line]
// [Explanation of what the bootstrap does — DI wiring, middleware registration, etc.]
[actual code snippet]
```

### Core Abstractions

**[Abstraction name — e.g., Repository Interface]**
What it is: [explanation]. Why it exists: [reason].

```[language]
// Definition — [file]:[line]
[interface or abstract type definition]
```

```[language]
// Usage — [file]:[line]
[how to implement or use it]
```

All implementations: `[file1]`, `[file2]`, `[file3]`

---

**[Abstraction 2 — e.g., Service base class / Middleware pattern]**
[repeat structure]

---

## 6. Data Model

<!-- diagram-tool: mermaid -->
```mermaid
%%{init: {'theme': 'neutral'}}%%
erDiagram
    TABLE_A {
        uuid id PK
        varchar name "NOT NULL"
        varchar status "DEFAULT 'active'"
        timestamp created_at "NOT NULL"
        timestamp updated_at "NOT NULL"
        timestamp deleted_at "NULL — soft delete"
    }
    TABLE_B {
        uuid id PK
        uuid table_a_id FK
        varchar type "NOT NULL"
        jsonb metadata "DEFAULT '{}'"
        timestamp created_at "NOT NULL"
    }
    TABLE_A ||--o{ TABLE_B : "has many"
```

### Entity Descriptions

**TABLE_A** — [What it represents in the domain. When records are created. Lifecycle.]
- `status` — values: `active`, `suspended`, `deleted`. Transitions enforced in `[file]:[line]`
- `deleted_at` — soft delete. Records with non-null `deleted_at` are excluded from all queries via `[scope/filter name]` in `[file]`

**TABLE_B** — [What it represents.]
- `metadata` — free-form JSON. Expected keys: `[key1]` (meaning), `[key2]` (meaning)

### Index Strategy

| Table | Index Name | Columns | Type | Purpose |
|-------|-----------|---------|------|---------|
| [table] | idx_[table]_[col] | [col], [col] | B-tree | [why — e.g., filter by status + sort] |
| [table] | idx_[table]_[col]_gin | [col] | GIN | [why — e.g., full-text search] |

### Migrations

Tool: `[golang-migrate / Flyway / Alembic / knex]`
Files: `[migrations/]` — named `[timestamp]_[description].[up/down].sql`

```bash
# Create new migration
[create command] --name add_column_to_table_a

# Run pending
[run command]

# Rollback last
[rollback command]

# Check status
[status command]
```

---

## 7. API Reference

Base URL: `[https://domain/api/vN]`
Auth: `Authorization: Bearer <token>` — validated in `[middleware file]:[line]`

### Endpoints

| Method | Path | Description | Auth | Handler |
|--------|------|-------------|------|---------|
| POST | `/resource` | Create | Required | `[file]:[line]` |
| GET | `/resource/:id` | Get by ID | Required | `[file]:[line]` |
| PUT | `/resource/:id` | Update | Required | `[file]:[line]` |
| DELETE | `/resource/:id` | Soft delete | Admin | `[file]:[line]` |
| GET | `/resources` | List (paginated) | Required | `[file]:[line]` |
| GET | `/health` | Health check | None | `[file]:[line]` |

### POST /resource

Request:
```json
{
  "name": "string — required, 1–255 chars",
  "type": "enum: typeA | typeB | typeC",
  "metadata": { "key": "value" }
}
```

Response `201`:
```json
{
  "id": "uuid",
  "name": "string",
  "type": "string",
  "status": "active",
  "metadata": {},
  "createdAt": "ISO-8601",
  "updatedAt": "ISO-8601"
}
```

### Error Codes

| Code | Message | HTTP | Retryable |
|------|---------|------|-----------|
| `VALIDATION_ERROR` | [field] is required | 400 | No — fix input |
| `UNAUTHORIZED` | Invalid or expired token | 401 | No — re-auth |
| `FORBIDDEN` | Insufficient permissions | 403 | No |
| `NOT_FOUND` | Resource not found | 404 | No |
| `CONFLICT` | [resource] already exists | 409 | No |
| `RATE_LIMITED` | Too many requests | 429 | Yes — after backoff |
| `INTERNAL_ERROR` | Internal server error | 500 | Yes |
| `UNAVAILABLE` | Service temporarily unavailable | 503 | Yes |

### Pagination

```
GET /resources?cursor=<token>&limit=20&sort=createdAt:desc

Response:
{
  "data": [...],
  "pagination": {
    "nextCursor": "token_or_null",
    "hasMore": true,
    "totalCount": 142
  }
}
```

---

## 8. System Behavior

### State Machine

<!-- diagram-tool: mermaid -->
```mermaid
%%{init: {'theme': 'neutral'}}%%
stateDiagram-v2
    [*] --> Created : create()
    Created --> Active : activate()
    Created --> Cancelled : cancel()
    Active --> Suspended : suspend()
    Active --> Completed : complete()
    Suspended --> Active : resume()
    Suspended --> Cancelled : cancel()
    Completed --> [*]
    Cancelled --> [*]
```

| From | To | Trigger | Guard condition |
|------|----|---------|-----------------|
| Created | Active | `activate()` | All required fields set |
| Active | Suspended | `suspend()` | Caller has admin role |
| Suspended | Active | `resume()` | Suspension reason resolved |

Transitions enforced in: `[file]:[line]`

### Event Design

<!-- diagram-tool: mermaid -->
```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart LR
    subgraph Producers["Producers"]
        SVC[Service]
    end

    subgraph Broker["Message Broker"]
        T1[resource.created]
        T2[resource.updated]
        T3[resource.deleted]
        DLQ[Dead Letter Queue]
    end

    subgraph Consumers["Consumers"]
        N[Notification Worker]
        A[Analytics Worker]
        S[Search Indexer]
    end

    SVC --> T1 & T2 & T3
    T1 --> N & A
    T2 & T3 --> S
    T1 -.->|3 retries failed| DLQ
    T2 -.->|3 retries failed| DLQ

    style Producers fill:#E3F2FD,stroke:#4A90D9
    style Broker fill:#FAFAFA,stroke:#9E9E9E
    style Consumers fill:#E8F5E9,stroke:#7CB342
```

Event schema (CloudEvents):
```json
{
  "id": "uuid",
  "type": "resource.created",
  "source": "[service-name]",
  "time": "ISO-8601",
  "datacontenttype": "application/json",
  "data": {
    "resourceId": "uuid",
    "changes": {}
  },
  "metadata": {
    "correlationId": "uuid",
    "version": 1
  }
}
```

### Error Handling

| Category | Example | Action |
|----------|---------|--------|
| Validation | Missing required field | Return 400 immediately, no retry |
| Business | Duplicate resource name | Return 409 immediately, no retry |
| Transient | DB connection timeout | Retry with exponential backoff |
| Fatal | Schema migration mismatch | Alert + fail fast, do not retry |

Retry config (from `[file]`):
```yaml
retry:
  maxAttempts: 3
  initialDelay: 100ms
  maxDelay: 5s
  multiplier: 2.0
  retryableErrors: [DEADLINE_EXCEEDED, UNAVAILABLE, RESOURCE_EXHAUSTED]
```

Circuit breaker config (from `[file]`):
```yaml
circuitBreaker:
  failureThreshold: 5    # trips after 5 consecutive failures
  successThreshold: 3    # resets after 3 successes in half-open state
  timeout: 30s           # moves to half-open after 30s
```

Fallback behavior:
| Scenario | Fallback |
|----------|----------|
| Cache miss | Read from primary DB |
| Primary DB down | Read from replica (stale reads acceptable) |
| Queue down | Write to outbox table (`[table]`), retry via `[worker file]` |

---

## 9. Data Flow Walkthroughs

### Flow 1: [Most important operation — e.g., Create Resource]

**Step by step:**
1. Client sends `POST /api/v1/resource` with `Authorization: Bearer <token>`
2. `[AuthMiddleware]` (`[file]:[line]`) validates JWT, attaches `user` to request context
3. `[ResourceHandler].create` (`[file]:[line]`) parses and validates request body
4. Calls `[ResourceService].create(cmd)` (`[file]:[line]`)
5. Service checks for name collision via `[Repository].findByName` (`[file]:[line]`)
6. Inserts record — `[Repository].insert(entity)` (`[file]:[line]`)
7. Emits `resource.created` event to queue (`[file]:[line]`)
8. Returns `ResourceDTO` → handler returns `201`

<!-- diagram-tool: mermaid -->
```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    actor Client
    participant MW as AuthMiddleware
    participant H as ResourceHandler
    participant S as ResourceService
    participant R as Repository
    participant DB as Database
    participant Q as Queue

    Client->>MW: POST /api/v1/resource + Bearer token
    MW->>MW: Validate JWT
    MW->>H: req + user context
    H->>H: Validate body
    H->>S: create(cmd)
    S->>R: findByName(name)
    R->>DB: SELECT WHERE name = ?
    DB-->>R: null
    S->>R: insert(entity)
    R->>DB: INSERT INTO [table]
    DB-->>R: created row
    S->>Q: emit resource.created
    S-->>H: ResourceDTO
    H-->>Client: 201 + body
```

**Failure paths:**
- Invalid token → `AuthMiddleware` returns 401, never reaches handler
- Validation fails → `ResourceHandler` returns 400, service never called
- Duplicate name → service returns 409, DB rolled back
- DB down → service throws, global error handler returns 503, event not emitted, outbox picks it up

---

### Flow 2: [Second important operation]

[repeat structure]

---

## 10. Non-Functional Requirements

| Category | Requirement | Target | Measurement |
|----------|------------|--------|-------------|
| Availability | Uptime | 99.9% | Uptime monitor |
| Latency | P99 response time | < 500ms | APM traces |
| Throughput | Peak RPS | [N] RPS | Load tests |
| Scalability | Horizontal scale range | [min]–[max] instances | Auto-scaler metrics |
| Data retention | Log retention | 90 days | Storage policy |
| RTO | Recovery time objective | < 30 min | Runbook |
| RPO | Recovery point objective | < 5 min | Backup schedule |

---

## 11. Infrastructure & Deployment

<!-- diagram-tool: mermaid -->
```mermaid
%%{init: {'theme': 'neutral'}}%%
graph TB
    subgraph Cloud["Cloud Provider"]
        DNS[Route 53 / DNS]
        CDN[CloudFront / CDN]
        LB[Load Balancer]

        subgraph AZ1["Availability Zone 1"]
            S1[Service Instance]
        end
        subgraph AZ2["Availability Zone 2"]
            S2[Service Instance]
        end

        DB_P[(Primary DB)]
        DB_R[(Replica DB)]
        CACHE[(Cache Cluster)]
        QUEUE[Queue]
    end

    DNS --> CDN --> LB
    LB --> S1 & S2
    S1 & S2 --> DB_P
    S1 & S2 --> CACHE
    DB_P -.->|replication| DB_R
    S1 & S2 --> QUEUE

    style Cloud fill:#FAFAFA,stroke:#9E9E9E
```

### CI/CD Pipeline

Trigger: [push to main / PR merge / git tag]

| Stage | What it does | Approx time |
|-------|-------------|-------------|
| Test | Runs full test suite | ~[N] min |
| Lint | Runs linter + type checker | ~[N] min |
| Build | Builds + pushes Docker image | ~[N] min |
| Deploy staging | Auto-deploys on merge to main | ~[N] min |
| Deploy prod | Manual approval required | ~[N] min |

Pipeline defined in: `[.github/workflows/deploy.yml]`

### Environments

| Env | URL | How to deploy | DB |
|-----|-----|--------------|-----|
| Local | `localhost:[port]` | `docker-compose up` | Docker |
| Staging | `[url]` | Merge to `main` | `[DB identifier]` |
| Production | `[url]` | Approve in CI | `[DB identifier]` |

### Deploy to Production

```bash
# [Exact steps — e.g.:]
# 1. Merge PR to main (triggers staging deploy automatically)
# 2. Verify staging at [staging URL]
# 3. Approve production deploy in [CI/CD UI URL]
# 4. Monitor [dashboard URL] for 10 min post-deploy
```

### Rollback

```bash
# [Exact command or procedure]
[rollback command]
```

---

## 12. Monitoring & Observability

### Key Metrics

| Metric | Type | Alert threshold |
|--------|------|----------------|
| `[http_requests_total]` | Counter | Error rate > 1% |
| `[http_request_duration]` | Histogram | P99 > 1s |
| `[db_connection_pool_size]` | Gauge | Utilization > 80% |
| `[queue_depth]` | Gauge | > [N] messages |
| `[cpu_utilization]` | Gauge | > 80% |

### Dashboards
- [Service overview — URL or description]
- [DB performance — URL or description]
- [Error tracking — Sentry/Datadog URL]

### Logs

Format: structured JSON. Shipped to: [ELK / CloudWatch / Datadog].

Correlation ID: `X-Correlation-ID` header → injected into every log line in `[middleware file]:[line]`.

Log levels: `ERROR` = alert, `WARN` = degradation, `INFO` = audit trail, `DEBUG` = local only.

Query example (find errors for a request):
```
[log query for your platform — e.g., CloudWatch Insights or Datadog]
```

---

## 13. Security

### Auth Flow

Method: [JWT / OAuth2 / API Key]
Validation: `[AuthMiddleware]` (`[file]:[line]`) — validates signature, expiry, and audience.

RBAC roles:
| Role | What it can do |
|------|---------------|
| `admin` | All operations including delete |
| `editor` | Create and update |
| `viewer` | Read only |

Role is stored in the JWT `claims.[role]` field and checked in `[file]:[line]`.

### Input Validation

Validation runs in `[handler / schema file]`. Rules:

| Field | Rule |
|-------|------|
| `name` | 1–255 chars, alphanumeric + hyphens, required |
| `type` | Enum whitelist: `[value1, value2]` |
| `metadata` | Max 50 keys, key length ≤ 64 chars |

### Encryption

- **At rest:** [AES-256 / DB-level encryption] for [which fields]. Keys managed by [KMS/Vault].
- **In transit:** TLS [1.2/1.3] enforced for all connections. Certificate from [ACM/Let's Encrypt].
- **Secrets:** Stored in [AWS Secrets Manager / Vault / environment only]. Never committed to repo. Loaded in `[config file]:[line]`.

### OWASP Checklist

| Item | Status |
|------|--------|
| SQL injection — parameterized queries | ☐ |
| XSS — output encoding | ☐ |
| CSRF protection | ☐ |
| Rate limiting | ☐ |
| Security headers (CSP, HSTS, X-Frame-Options) | ☐ |
| Dependency vulnerability scanning | ☐ |
| Secrets never in source control | ☐ |

---

## 14. Local Development Setup

### Prerequisites

| Tool | Version | Check | Install |
|------|---------|-------|---------|
| [Runtime] | [exact version from .nvmrc/go.mod] | `[cmd] --version` | [how] |
| Docker | 24+ | `docker --version` | docker.com |
| [DB CLI] | [version] | `[cmd] --version` | `brew install [pkg]` |
| Make | 3.8+ | `make --version` | pre-installed on macOS |

### Setup

```bash
# 1. Clone
git clone [repo-url]
cd [repo-name]

# 2. Install dependencies
[npm install / go mod download / pip install -r requirements.txt]

# 3. Start local infrastructure (DB, cache, queue)
docker-compose up -d

# 4. Configure environment
cp .env.example .env
# Required vars to fill in (all others have safe defaults):
# [VAR_NAME] — [what it needs to be for local dev]
# [VAR_NAME] — [what it needs to be for local dev]

# 5. Run migrations
[migration run command]

# 6. Seed development data
[seed command]
# Seeded: [N] users, [N] resources — login with [test credentials]

# 7. Start the app
[start command]
# App running at http://localhost:[port]
```

### Verify

```bash
curl http://localhost:[port]/health
# Expected: {"status":"ok","version":"[version]"}
```

---

## 15. Daily Developer Workflows

All commands available via `make help` or `[npm run / go run]`.

### Run Tests

```bash
[make test]                          # all tests
[make test-unit]                     # unit only
[make test-integration]              # integration only (requires docker-compose up)
[make test-e2e]                      # end-to-end
[test command] [path/to/file.test]   # single file
[test command] --grep "[pattern]"    # matching name pattern
[test command] --coverage            # with coverage report (opens at [URL])
```

### Add a New API Endpoint

1. Add route: `[router file]` — follow the pattern on line [N]
2. Create handler: `[src/api/handlers/resource.ts]` — copy from existing handler
3. Add service method: `[src/services/resource.ts]`
4. Add repository method: `[src/repo/resource.ts]` (if DB access needed)
5. Add validation schema: `[src/schemas/]`
6. Write integration test: `[tests/api/resource.test]`

### Add a Database Migration

```bash
[migration create command] --name describe_what_changes
# Creates: [migrations/TIMESTAMP_describe_what_changes.up.sql]
#          [migrations/TIMESTAMP_describe_what_changes.down.sql]

# Edit the files, then:
[migration run command]

# Verify schema:
[migration status command]

# Rollback if needed:
[rollback command]
```

### Add a Background Job

[Steps specific to the job framework used in this repo]

### Debug Locally

```bash
[start command with debug flag]
# Debugger listening on port [N]
```

VS Code: use config in `.vscode/launch.json` → "Debug [service name]"

### Lint & Format

```bash
[lint command]        # check only
[lint fix command]    # auto-fix
[format command]      # format
[typecheck command]   # type check (if applicable)
```

---

## 16. Configuration & Environment Variables

Loaded by `[config file]:[line]`. The app **will refuse to start** if any `required` var is missing.

### Application

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PORT` | No | `8080` | HTTP server port |
| `LOG_LEVEL` | No | `info` | `debug` / `info` / `warn` / `error` |
| `APP_ENV` | Yes | — | `development` / `staging` / `production` |

### Database

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | Yes | — | Full connection string, e.g. `postgres://user:pass@host:5432/db` |
| `DB_MAX_CONNECTIONS` | No | `25` | Max connection pool size |
| `DB_IDLE_CONNECTIONS` | No | `5` | Idle connections kept open |

### External Services

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `[SERVICE]_API_KEY` | Yes | — | [Purpose] |
| `[SERVICE]_BASE_URL` | Yes | — | Base URL for [service] |

### Feature Flags

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `ENABLE_[FEATURE]` | No | `false` | Enables [feature description] |

---

## 17. Testing Guide

### Structure

```
[tests/]
├── unit/           # Pure logic, no I/O — fast, no docker required
├── integration/    # Real DB via testcontainers — requires docker
└── e2e/            # Full HTTP against running app
```

Coverage target: [N]%. Check with `[coverage command]`.

### Write a Unit Test

```[language]
// Follow this pattern — from [tests/unit/example.test]:[line]
[real test from the codebase — describe block, it/test block, assertions]
```

### Write an Integration Test

```[language]
// Follow this pattern — from [tests/integration/example.test]:[line]
// Note: DB is reset between each test via [helper/fixture]
[real integration test showing setup, action, assertion, teardown]
```

### Mocking Strategy

| Dependency | Tool | Pattern |
|-----------|------|---------|
| External HTTP APIs | [msw / nock / httptest] | [describe pattern — e.g., intercept at network level] |
| Database | [testcontainers / in-memory] | [describe — e.g., spin up real PG in Docker per test suite] |
| Time/clocks | [sinon / jest.useFakeTimers / clockwork] | [describe] |
| Message queue | [in-memory broker / mock] | [describe] |

---

## 18. Coding Conventions

Derived from this codebase — not generic rules.

### File Naming
[e.g., `kebab-case.ts` for files, `PascalCase` for classes, one exported concept per file]

### Function & Variable Naming
[Rules with examples from this codebase]

### Error Handling Pattern

```[language]
// The pattern used throughout this codebase — [file]:[line]
[real snippet showing how errors are created, wrapped, and propagated]
```

Rule: **never swallow errors**. If you catch, either handle fully or re-throw with added context.

### Logging Pattern

```[language]
// Use the shared logger — [file]:[line]
// Never use console.log in production code
[real logging snippet showing structured log with context fields]
```

### Layering Rules

- **Handlers** — parse input, call one service method, return response. No business logic.
- **Services** — business logic, orchestration. No direct DB calls.
- **Repositories** — all DB queries. No business logic.
- **Models** — data shape + validation only. No I/O.

### What NOT To Do

| Anti-pattern | Why it's wrong | What to do instead |
|---|---|---|
| Business logic in a handler | Untestable without HTTP setup | Move to service layer |
| Direct DB query in a service | Bypasses transaction management | Use repository |
| Catching errors and returning null | Hides failures, hard to debug | Propagate with context |
| `console.log` in production code | Unstructured, not queryable | Use the shared logger |
| [Other anti-pattern from this repo] | [Why] | [Alternative] |

---

## 19. Design Decisions

### Summary

| # | Decision | Category | Chosen | Key Trade-off |
|---|----------|----------|--------|---------------|
| 1 | [e.g., Web framework] | Technology | [e.g., Gin] | [e.g., Less magic, but more boilerplate than full-stack alternatives] |
| 2 | [e.g., Primary data store] | Data | [e.g., PostgreSQL] | [e.g., Strong consistency, but harder to scale writes horizontally] |
| 3 | [e.g., Auth approach] | Auth | [e.g., JWT stateless] | [e.g., No session store needed, but revocation requires a blocklist] |
| 4 | [e.g., Pagination] | API | [e.g., Cursor-based] | [e.g., Stable under inserts, but can't jump to page N] |
| 5 | [e.g., Event system] | Architecture | [e.g., SQS] | [e.g., Managed, but no consumer groups — fan-out requires SNS] |

*(add one row per significant decision — aim for 10–15)*

---

### ADR-1: [Precise Title — e.g., "PostgreSQL over MongoDB as primary data store"]

**Category:** Technology | Architecture | Data | API | Auth | Testing | Deployment | Cross-cutting

**Context**
[What problem or need drove this decision? What constraints existed — team size, existing infra, data shape, scale requirements?]

**Options Considered**
- **[Option A]** — [one sentence: key characteristic relevant to this decision]
- **[Option B]** — [one sentence]
- **[Option C]** (if applicable)

**Decision**
[Option X was chosen.]

**Rationale**
[Why this option — specific to this codebase, not generic.]

**Trade-offs Accepted**
- [What became harder or impossible]
- [What future flexibility is reduced]

**Consequences**
- Developer experience: [effect]
- Operations: [effect]
- Future scalability: [effect]

Evidence: `[file:line or library name from manifest]`

---

### ADR-2: [Next Decision]

*(repeat ADR block for each row in the summary table)*

---

## 20. Risks & Mitigations

| # | Risk | Probability | Impact | Mitigation | Owner |
|---|------|------------|--------|------------|-------|
| 1 | [e.g., DB is SPOF] | Low | High | Read replica + automated failover | Platform team |
| 2 | [e.g., Queue backpressure] | Medium | Medium | DLQ + alerts on depth > [N] | Backend team |
| 3 | [e.g., Third-party API outage] | Medium | High | Circuit breaker + fallback response | Backend team |
| 4 | [e.g., Secrets leak] | Low | Critical | Vault rotation + secret scanning in CI | Security team |
| 5 | [Risk] | [H/M/L] | [H/M/L] | [Mitigation] | [Team] |

---

## 21. Gotchas & FAQs

**Q: I added a field to the model but it's not showing up in the API response — why?**
A: The DTO serializer in `[src/api/serializers/]` is explicit — add the field there too. `[file]:[line]`

**Q: My test passes locally but fails in CI — why?**
A: Tests run in parallel in CI. If your test relies on insertion order or shared state, it'll fail non-deterministically. Use explicit ordering or isolated test data. See `[tests/helpers/db]:[line]` for how tests are isolated.

**Q: Why does the app take [N] seconds to start locally?**
A: It runs all pending DB migrations on startup. Check `[bootstrap file]:[line]`

**Q: How do I reset my local database completely?**
```bash
[exact command — e.g., make db-reset]
```

**Q: Why is there a `[confusing pattern]` in `[file]`?**
A: [Historical reason or deliberate trade-off. `[file]:[line]`]

**Q: What's the difference between `[thing A]` and `[thing B]`?**
A: [Explanation]

**Q: I'm getting `[specific error message]` — what does it mean?**
A: [What causes it + how to fix it]

**Q: Why does `[operation]` sometimes return stale data?**
A: [e.g., The cache TTL is [N] minutes. Set in `[file]:[line]`. During that window, updates to the DB aren't reflected. For critical reads, use `[bypass pattern]`.]

**Q: How do I run only the tests for one module?**
```bash
[exact command]
```

**Q: The linter is failing on a rule I disagree with — what do I do?**
A: [Process — e.g., discuss in PR, don't add inline suppression comments without explanation]

---

## 22. First Week Checklist

### Day 1 — Get oriented
- [ ] Complete local setup ([Section 14](#14-local-development-setup)) — app starts, health check passes
- [ ] Read the repo structure ([Section 2](#2-repo-structure)) and the "Start Here" files
- [ ] Read the architecture overview ([Sections 3–4](#3-system-context))
- [ ] Read the data model ([Section 6](#6-data-model)) — understand the core entities

### Day 2 — Run and explore
- [ ] Run the full test suite — all tests pass
- [ ] Read the daily workflows ([Section 15](#15-daily-developer-workflows))
- [ ] Step through one data flow ([Section 9](#9-data-flow-walkthroughs)) in your debugger
- [ ] Make a trivial change (add a log line, fix a typo) and open a PR

### Day 3 — Contribute
- [ ] Implement one small feature end-to-end: route → handler → service → repository → test
- [ ] Read coding conventions and gotchas ([Sections 18](#18-coding-conventions), [21](#21-gotchas--faqs))
- [ ] Read the design decisions ([Section 19](#19-design-decisions)) to understand the "why"

### Contacts

| Area | Owner | How to reach |
|------|-------|-------------|
| Backend / API | [Name or team] | [Slack channel / email] |
| Database / Data model | [Name or team] | [Slack channel / email] |
| Infrastructure / DevOps | [Name or team] | [Slack channel / email] |
| Product / Domain questions | [Name or team] | [Slack channel / email] |
| Security | [Name or team] | [Slack channel / email] |
