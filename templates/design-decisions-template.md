# Design Decisions & Trade-offs: [System Name]

**Author:** [Name]
**Date:** [Date]
**Status:** Draft | In Review | Approved
**Codebase:** [Repo URL]

> This document captures the "why" behind every significant architectural and technical choice in this codebase. New engineers should read this alongside the architecture overview to understand not just *what* was built, but *why* it was built this way — and what flexibility was traded away in the process.

---

## Table of Contents

1. [Summary Table](#summary-table)
2. [Full ADRs](#full-adrs)
   - [ADR-1: Framework Choice](#adr-1-framework-choice)
   - [ADR-2: Database Type](#adr-2-database-type)
   - [ADR-3: ORM vs Raw SQL](#adr-3-orm-vs-raw-sql)
   - [ADR-4: Authentication Mechanism](#adr-4-authentication-mechanism)
   - [ADR-5: API Style](#adr-5-api-style)
   - *(add more as needed)*

---

## Summary Table

| # | Decision | Category | Chosen | Key Trade-off |
|---|----------|----------|--------|---------------|
| 1 | [e.g., Web framework] | Technology | [e.g., Gin] | [e.g., Less magic than full-stack frameworks, but more boilerplate] |
| 2 | [e.g., Primary data store] | Data | [e.g., PostgreSQL] | [e.g., Strong consistency + relational joins, but harder to scale writes horizontally] |
| 3 | [e.g., Auth approach] | Auth | [e.g., JWT, stateless] | [e.g., No server-side session state, but token revocation requires a blocklist] |
| 4 | [e.g., Pagination strategy] | API | [e.g., Cursor-based] | [e.g., Stable under concurrent inserts, but can't jump to page N directly] |
| 5 | [e.g., Event messaging] | Architecture | [e.g., SQS] | [e.g., Managed, no ops burden, but no consumer groups — fan-out needs SNS] |
| 6 | [e.g., ORM vs raw SQL] | Data | [e.g., Raw SQL + sqlx] | [e.g., Full query control, but more boilerplate than ORM] |
| 7 | [e.g., Caching strategy] | Data | [e.g., Redis, aside cache] | [e.g., Read performance, but cache invalidation complexity] |
| 8 | [e.g., Monolith vs services] | Architecture | [e.g., Modular monolith] | [e.g., Simple deployment, but harder to scale individual components independently] |
| 9 | [e.g., Error handling] | Cross-cutting | [e.g., Typed error wrapping] | [e.g., Rich error context, but verbose] |
| 10 | [e.g., Config management] | Cross-cutting | [e.g., Env vars + struct validation] | [e.g., 12-factor compliant, but no runtime reload] |

---

## Full ADRs

---

### ADR-1: Framework Choice

**Category:** Technology

**Context**
[What was being built? What were the team's constraints — language ecosystem, performance requirements, team familiarity? What triggered the decision?]

**Options Considered**
- **[Framework A]** — [one sentence: key characteristic relevant to the decision]
- **[Framework B]** — [one sentence]
- **[Framework C]** — [one sentence]

**Decision**
[Framework X was chosen.]

**Rationale**
[Specific reasons for this codebase — not generic "it's popular" but what properties were actually needed.]

**Trade-offs Accepted**
- [What became harder with this choice]
- [What you give up vs an alternative]

**Consequences**
- Developer experience: [how it affects day-to-day coding]
- Operations: [deployment, monitoring, debugging implications]
- Flexibility: [what future migrations would require]

Evidence: `[go.mod:1 / package.json:5 / etc.]`

---

### ADR-2: Database Type

**Category:** Data

**Context**
[What is the data shape? What are the access patterns — point lookups, complex joins, time-series, document storage? Scale expectations?]

**Options Considered**
- **PostgreSQL** — relational, ACID, strong consistency, rich query language, mature tooling
- **MongoDB** — document store, flexible schema, horizontal scale-out, weaker consistency guarantees
- **[Other]** — [description]

**Decision**
[X was chosen.]

**Rationale**
[Why — specific to the data model and access patterns of this system.]

**Trade-offs Accepted**
- [What's harder — e.g., horizontal write scaling, schema migrations with live traffic]
- [What's given up]

**Consequences**
- Schema changes require versioned migrations (`[migration tool]`)
- Joins are cheap; denormalization is rarely needed
- Horizontal write scaling would require sharding or Citus

Evidence: `[migrations/0001_init.sql, go.mod: lib/pq or pgx]`

---

### ADR-3: ORM vs Raw SQL

**Category:** Data

**Context**
[How complex are the queries? Is the team comfortable with SQL? Is query control or development speed more important?]

**Options Considered**
- **ORM (e.g., GORM, Hibernate, SQLAlchemy)** — less boilerplate, auto-migration, but hides query behavior, harder to optimize
- **Raw SQL + thin mapper (e.g., sqlx, pgx, database/sql)** — full control, explicit, but more verbose
- **Query builder (e.g., squirrel, knex)** — composable queries, no magic, still SQL-shaped

**Decision**
[X was chosen.]

**Rationale**
[Why.]

**Trade-offs Accepted**
- [What's harder]

**Consequences**
- All queries visible in repository files — easy to audit and optimize
- No auto-migration — schema changes always go through versioned migrations

Evidence: `[src/repo/*.go or similar]`

---

### ADR-4: Authentication Mechanism

**Category:** Auth

**Context**
[Is this a user-facing API, machine-to-machine, or both? What are the session requirements? Is revocation needed?]

**Options Considered**
- **JWT (stateless)** — self-contained token, no server-side state, but revocation requires a blocklist
- **Session cookies (stateful)** — easy revocation, but requires session store, not suitable for mobile/SPA
- **API keys** — simple for machine-to-machine, no expiry by default
- **OAuth2 / OIDC** — delegated auth, good for third-party integrations, more complex setup

**Decision**
[X was chosen.]

**Rationale**
[Why — consider: who the callers are, stateless vs stateful requirements, revocation needs.]

**Trade-offs Accepted**
- [e.g., JWT: tokens live until expiry — compromised tokens can't be invalidated without blocklist]
- [e.g., Sessions: requires Redis or DB for session store]

**Consequences**
- Token validation in `[middleware file]:[line]`
- [Other consequences]

Evidence: `[auth middleware file, JWT library in manifest]`

---

### ADR-5: API Style

**Category:** API

**Context**
[Who are the clients — web, mobile, third parties, internal services? What are the query complexity needs? Is a typed contract needed?]

**Options Considered**
- **REST** — simple, widely understood, resource-oriented, good tooling ecosystem
- **GraphQL** — flexible queries, single endpoint, client-driven, but complex caching and N+1 risk
- **gRPC** — efficient binary protocol, strong typing via proto, but requires code generation and HTTP/2

**Decision**
[X was chosen.]

**Rationale**
[Why — specific to the clients and data needs of this system.]

**Trade-offs Accepted**
- [What's harder with the chosen style]

**Consequences**
- [Effect on client development]
- [Effect on API evolution/versioning]

Evidence: `[router file, .proto files if gRPC, .graphql if GraphQL]`

---

### ADR-6: [Next Decision]

**Category:** [Category]

**Context**
[...]

**Options Considered**
- **[A]** — [...]
- **[B]** — [...]

**Decision**
[...]

**Rationale**
[...]

**Trade-offs Accepted**
- [...]

**Consequences**
- [...]

Evidence: `[file:line]`

---

*(Add one ADR block per significant decision. Aim for 10–15 total.)*
