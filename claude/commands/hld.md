Generate a **High-Level Design (HLD)** document for: $ARGUMENTS

Use the HLD template from `templates/hld-template.md` as a starting point. Fill in all sections with concrete details specific to this system.

## Required Sections (10 total)

1. **Overview** — Problem statement, goals, scope, audience
2. **System Context Diagram** — Use **Excalidraw MCP** (`create_view`) for the hero diagram showing the system boundary, actors, and external dependencies
3. **Architecture Diagram** — Use **Mermaid** component diagram showing internal services, their responsibilities, and communication patterns
4. **Design Decisions** — ADR-style table: Decision, Options Considered, Chosen, Rationale
5. **Data Flow** — **Mermaid** sequence diagrams for the happy path AND primary error path
6. **Data Model** — **Mermaid** ER diagram showing core entities and relationships
7. **Non-Functional Requirements** — Table with: Category, Requirement, Target, Measurement
8. **Infrastructure & Deployment** — **Mermaid** deployment diagram; if cloud architecture needs provider icons, also generate a **Python Diagrams** script in `examples/`
9. **Monitoring & Observability** — Key metrics, alerting thresholds, dashboards, log aggregation strategy
10. **Risks & Mitigations** — Risk matrix with probability, impact, mitigation, and owner

## Diagram Rules

- Follow the hybrid diagram strategy from CLAUDE.md
- Add `<!-- diagram-tool: mermaid|excalidraw|python-diagrams -->` above each diagram
- Use `%%{init: {'theme': 'neutral'}}%%` for all Mermaid diagrams
- Apply color coding: Blue=core, Green=external, Yellow=data, Red=security, Grey=infra

## Output

- Save the completed HLD to `docs/designs/hld-<system-name>.md`
- Save any generated diagrams to `docs/diagrams/`
- Print a summary of what was created when done
