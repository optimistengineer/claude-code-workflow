Generate a **Low-Level Design (LLD)** document for: $ARGUMENTS

Use the LLD template from `templates/lld-template.md` as a starting point. Fill in all sections with concrete details specific to this module/component.

## Required Sections (12 total)

1. **Overview** — Module purpose, boundaries, dependencies, tech stack
2. **Module Architecture** — Use **Excalidraw MCP** (`create_view`) for the hero diagram showing internal module structure, layers, and key interfaces
3. **Class/Module Design** — **Mermaid** class diagram showing classes/modules, methods, relationships, and design patterns used
4. **API Design** — Full API specification:
   - Endpoint table: Method, Path, Description, Auth
   - Request/response JSON schemas with examples
   - Error codes table: Code, Message, HTTP Status, Retry
   - Rate limiting and pagination strategy
5. **API Flow** — **Mermaid** sequence diagram showing the full request lifecycle including auth, validation, business logic, and data access
6. **Database Design** — **Mermaid** ER diagram with:
   - Table definitions including columns, types, constraints
   - Index strategy table: Table, Index Name, Columns, Type, Purpose
   - Migration strategy
7. **Event Design** — **Mermaid** flowchart showing event producers, topics/queues, consumers, and DLQ handling
8. **State Machine** — **Mermaid** state diagram for the primary entity lifecycle
9. **Error Handling** — Error taxonomy, retry strategy with backoff, circuit breaker config, fallback behavior
10. **Configuration** — YAML config structure with defaults, environment overrides, and feature flags
11. **Testing Strategy** — Test pyramid: unit/integration/e2e counts, key test scenarios, mocking strategy
12. **Security** — Auth flow, input validation rules, encryption (at-rest & in-transit), OWASP checklist

## Diagram Rules

- Follow the hybrid diagram strategy from CLAUDE.md
- Add `<!-- diagram-tool: mermaid|excalidraw|python-diagrams -->` above each diagram
- Use `%%{init: {'theme': 'neutral'}}%%` for all Mermaid diagrams
- Apply color coding: Blue=core, Green=external, Yellow=data, Red=security, Grey=infra

## Output

- Save the completed LLD to `docs/designs/lld-<module-name>.md`
- Save any generated diagrams to `docs/diagrams/`
- Print a summary of what was created when done
