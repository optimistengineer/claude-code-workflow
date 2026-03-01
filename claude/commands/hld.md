Generate a **High-Level Design (HLD)** document for: $ARGUMENTS

First research the system: read relevant code, configs, and existing docs to understand the domain before writing.

## Document Structure

Use this metadata header, then fill in all 10 sections below:

```
# High-Level Design: <System Name>
Author: | Date: | Status: Draft | Version: 1.0
```

### 1. Overview
Problem statement, goals (as checklist), non-goals, target audience.

### 2. System Context ← Excalidraw hero diagram
Use **Excalidraw MCP** (`read_me` then `create_view`). Show system boundary, actors (users, admins, external systems), and all external dependencies.

### 3. Architecture ← Mermaid component diagram
`graph TB` with subgraphs: Core (Blue), External (Green), Data (Yellow). Include component responsibilities table and communication patterns table (From, To, Protocol, Pattern).

### 4. Design Decisions
ADR-style table: #, Decision, Options Considered, Chosen, Rationale.

### 5. Data Flow ← Mermaid sequence diagrams
Two diagrams: **happy path** (full request lifecycle) and **primary error path** (failure + DLQ/retry handling).

### 6. Data Model ← Mermaid ER diagram
Core entities with types, PK/FK constraints, and relationships.

### 7. Non-Functional Requirements
Table: Category, Requirement, Target, Measurement. Cover: availability, latency, throughput, scalability, data retention.

### 8. Infrastructure & Deployment ← Mermaid deployment diagram
Multi-AZ layout with LB, service instances, primary/replica DB. If cloud provider icons are needed, also generate a **Python Diagrams** script in `examples/`.

### 9. Monitoring & Observability
Key metrics table (metric, type, alert threshold), dashboards list, log aggregation strategy with correlation IDs.

### 10. Risks & Mitigations
Risk matrix: #, Risk, Probability, Impact, Mitigation, Owner.

End with **Appendix** (Glossary + References).

## Diagram Rules

- Follow the hybrid diagram strategy from CLAUDE.md
- Add `<!-- diagram-tool: mermaid|excalidraw|python-diagrams -->` above each diagram
- Use `%%{init: {'theme': 'neutral'}}%%` for all Mermaid diagrams
- Apply color coding: Blue=core, Green=external, Yellow=data, Red=security, Grey=infra
- Max 2 Excalidraw diagrams per doc (hero/overview only)

## Output

- Create `docs/designs/` directory if it doesn't exist
- Save the completed HLD to `docs/designs/hld-<system-name>.md`
- Save any diagram files to `docs/diagrams/`
- Print a summary of what was created when done
