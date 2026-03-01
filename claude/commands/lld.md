Generate a **Low-Level Design (LLD)** document for: $ARGUMENTS

First research the module: read relevant source code, existing HLD, configs, and schemas to understand the implementation context before writing.

## Document Structure

Use this metadata header, then fill in all 12 sections below:

```
# Low-Level Design: <Module Name>
Author: | Date: | Status: Draft | Version: 1.0 | Parent HLD: <link>
```

### 1. Overview
Module purpose, boundaries (owns vs delegates), dependency table (name, internal/external, purpose), tech stack table (layer, technology, version).

### 2. Module Architecture ← Excalidraw hero diagram
Use **Excalidraw MCP** (`read_me` then `create_view`). Show internal layers (API → Service → Repository), interfaces between layers, and connections to external systems.

### 3. Class/Module Design ← Mermaid class diagram
Classes with key methods and relationships. Include design patterns table (pattern, where, why).

### 4. API Design
- **Endpoints table:** Method, Path, Description, Auth
- **Request/response JSON schemas** with concrete examples for each endpoint
- **Error codes table:** Code, Message, HTTP Status, Retryable (yes/no)
- **Rate limiting table:** Endpoint, Limit, Window, Burst
- **Pagination:** cursor-based strategy with example response shape

### 5. API Flow ← Mermaid sequence diagram
Full request lifecycle: Client → Gateway → Auth → Service → Validation → DB → Cache invalidation → Event emission → Response.

### 6. Database Design ← Mermaid ER diagram
- Tables with columns, types, constraints (NOT NULL, DEFAULT, FK)
- **Index strategy table:** Table, Index Name, Columns, Type (B-tree/GIN/etc), Purpose
- Migration strategy (tool, reversibility, testing approach)

### 7. Event Design ← Mermaid flowchart
Producers → Topics/Queues → Consumers, with DLQ handling. Include CloudEvents-style event schema JSON example.

### 8. State Machine ← Mermaid state diagram
Primary entity lifecycle with all transitions. Include transition rules table (from, to, trigger, guard condition).

### 9. Error Handling
- Error taxonomy table (category, example, action)
- Retry config YAML (maxAttempts, delays, multiplier, retryable errors)
- Circuit breaker config YAML (thresholds, timeout, monitored exceptions)
- Fallback behavior table (scenario, fallback)

### 10. Configuration
YAML config block with defaults for: server, database, cache, feature flags. Show environment variable override pattern.

### 11. Testing Strategy
Test pyramid table (level, % target, what to test). Key test scenarios table (scenario, type, priority). Mocking strategy for external deps, DB, and events.

### 12. Security
Auth method + RBAC roles. Input validation rules table. Encryption (at-rest, in-transit, secrets management). OWASP checklist with checkboxes.

## Diagram Rules

- Follow the hybrid diagram strategy from CLAUDE.md
- Add `<!-- diagram-tool: mermaid|excalidraw|python-diagrams -->` above each diagram
- Use `%%{init: {'theme': 'neutral'}}%%` for all Mermaid diagrams
- Apply color coding: Blue=core, Green=external, Yellow=data, Red=security, Grey=infra
- Max 2 Excalidraw diagrams per doc (hero/overview only)

## Output

- Create `docs/designs/` directory if it doesn't exist
- Save the completed LLD to `docs/designs/lld-<module-name>.md`
- Save any diagram files to `docs/diagrams/`
- Print a summary of what was created when done
