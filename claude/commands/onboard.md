Generate a **complete onboarding document** for the codebase at: $ARGUMENTS

This document is written by a principal architect for a junior engineer. It must be exhaustive — the reader should never need to grep the codebase or ask a colleague to understand how the system works.

## Phase 1: Research (do this before writing a single line)

### 1. Read existing design docs first
Check `docs/designs/` for HLD and LLD files. If they exist, read them fully — they are the primary source for architecture, ADRs, API specs, DB schema, state machines, and NFRs. Do not regenerate what's already there; synthesize it.

### 2. Explore the repo systematically
- Directory tree: understand the full structure
- Entry points: `main.*`, `index.*`, `cmd/`, `app.*`, `server.*`, `Makefile`, `package.json` scripts
- Dependency manifest: `go.mod`, `package.json`, `requirements.txt`, `Gemfile`, `pom.xml`
- Config: `.env.example`, `config.*`, `*.yaml`, `*.toml`
- CI/CD: `.github/workflows/`, `Dockerfile`, `docker-compose.*`, deployment scripts
- Core modules: read the most-imported packages/modules, the key interfaces, and the central data types
- Tests: read representative test files to understand patterns and what's covered
- Migrations: read DB migration files to understand schema history

### 3. Discover the real details
Extract actual values — real env var names, real file paths, real function signatures, real command strings. Never use placeholders like `<your-value>` when the real value exists in the code.

---

## Document Structure (17 sections)

### 1. What Is This System?
One punchy paragraph: what it does, who uses it, what problem it solves. Then: key business domain concepts — define every domain term a new engineer will encounter (as a glossary table: Term, Definition, Where it appears in code).

### 2. Repo Structure
Annotated directory tree showing every top-level directory and key files. For each entry: what it contains and when a developer touches it. Include a "start here" callout for the 3-5 files to read first.

### 3. Architecture Overview ← Excalidraw hero diagram
Use **Excalidraw MCP** (`read_me` then `create_view`) for a full system overview: all components, external dependencies, and data flows between them. Follow with a **Mermaid** component diagram (`graph TB`) for the internal architecture. If HLD exists, reference and extend it — don't duplicate.

### 4. Key Files Every Developer Must Know
Table: File path, What it does, When you'll need to change it. Include: entry points, core interfaces/abstractions, config loader, router/handler registration, DB models, key utilities. Minimum 8-10 entries. For each, include a short code snippet showing how it's used.

### 5. Core Abstractions & Design Patterns
For each major abstraction (interface, base class, middleware, decorator, HOC, etc.):
- What it is and why it exists
- Code snippet showing the definition
- Code snippet showing how to implement/use it
- Where all existing implementations live

### 6. Data Model ← Mermaid ER diagram
Full ER diagram with all tables/collections. For each entity: field descriptions, constraints, what it represents in the domain. If LLD exists, extend it with domain explanations. Include: soft delete patterns, audit fields, relationships explained in plain English.

### 7. API Reference
If LLD exists, pull from it. Otherwise, discover from routes/controllers. For every endpoint:
- Method, path, description, auth requirement
- Request body with real field names, types, validation rules
- Response shapes (success + error) with real examples
- Which service/function handles it (file:line)

### 8. Key Data Flow Walkthroughs ← Mermaid sequence diagrams
Pick the 2-3 most important user-facing operations (e.g., user signup, placing an order, processing a job). For each:
- Narrative walkthrough: step by step in plain English
- Sequence diagram showing every service, function call, and DB query
- Code pointers: file:line for each major step
- What can go wrong and how errors are handled

### 9. Local Development Setup
**Prerequisites** — exact tools and versions required (read from tooling configs).
**Step-by-step setup** — every command, in order, that takes a fresh machine to a running app. Include: cloning, dependency install, environment setup (every required env var with description and example value), database setup, seeding, starting the server. Every command must be copy-pasteable and correct.
**Verifying it works** — exact command to run and what healthy output looks like.

### 10. Daily Developer Workflows
For each workflow, provide the exact commands and file locations:
- Run all tests / run a single test / run tests matching a pattern
- Add a new API endpoint (step-by-step: where to add route, handler, service, tests)
- Add a new database migration (commands + what to edit)
- Add a background job/worker
- Run the linter / formatter / type checker
- Debug locally (how to attach a debugger or add breakpoints)
- Read logs locally

### 11. Configuration & Environment Variables
Table of every env var the system reads: Name, Required/Optional, Default, Description, Example value. Group by: app config, database, external services, feature flags. Note which file loads them and where they're validated.

### 12. Testing Guide
- How tests are organized (unit/integration/e2e locations)
- How to run each layer separately
- What's mocked and how (show the mock setup pattern)
- How to write a new unit test — complete example from the repo's style
- How to write a new integration test — complete example
- What test coverage targets are and how to check them

### 13. Coding Conventions
Extract the actual patterns used in this codebase:
- File and folder naming conventions
- Function/variable naming rules
- Error handling pattern (show the actual pattern used, not generic)
- Logging pattern (show how logs are structured in this codebase)
- Where business logic lives vs. where infrastructure code lives
- **What NOT to do** — anti-patterns found or implied in the codebase with explanation of why

### 14. Deployment & Operations
- CI/CD pipeline: what triggers it, what each stage does (read from workflow files)
- Environments: dev, staging, prod — what's different between them
- How to deploy: exact steps or which pipeline to trigger
- How to roll back
- How to check if the app is healthy (endpoint, dashboard, log query)
- Key runbooks: what to do when the DB is slow, when the queue backs up, when errors spike

### 15. Design Decisions (ADR Summary)
If HLD/LLD ADR tables exist, pull them here. Otherwise, infer key decisions from the code (choice of framework, DB, queue, auth approach, etc.) and document them as: Decision, Why this approach, Trade-offs accepted.

### 16. Gotchas & FAQs
Real gotchas discovered from reading the code — non-obvious behaviors, footguns, things that will confuse a new engineer. Format: **Q: [thing they'll wonder]** → **A: [explanation + code pointer]**. Minimum 8 entries. Examples of what to look for: implicit behaviors, global state, order-dependent initialization, timeout values, retry logic side effects, cache invalidation assumptions.

### 17. First Week Checklist
Ordered tasks to go from zero to productive:
- Day 1: environment setup + reading list (link to sections above)
- Day 2: run the test suite, make a trivial change, submit a PR
- Day 3: implement a small feature end-to-end using the workflows above
- Contacts: who owns what (fill from CODEOWNERS, git blame patterns, or leave placeholders)

---

## Diagram Rules
- Follow the hybrid strategy from CLAUDE.md
- Use `%%{init: {'theme': 'neutral'}}%%` for all Mermaid diagrams
- Add `<!-- diagram-tool: ... -->` above each diagram
- Max 2 Excalidraw diagrams (hero overview + 1 more if genuinely needed)

## Output
- Create `docs/` directory if it doesn't exist
- Save to `docs/onboarding.md`
- If HLD/LLD docs exist, add a note at the top of the doc linking to them
- Print a summary of sections written and key discoveries from the codebase
