# Global Claude Code Instructions

## Output Conventions

- Create output directories before writing: `docs/designs/`, `docs/diagrams/`
- Use kebab-case for filenames: `hld-payment-service.md`, `user-auth-flow.svg`
- Always read existing files/code before modifying or reviewing them
- Slash commands receive user input via `$ARGUMENTS`

## Hybrid Diagram Strategy

Use the right tool for each diagram type. Default to Mermaid (~80% of diagrams).

### Tool Selection

| Tool | When to Use | Max per Doc |
|------|-------------|-------------|
| **Mermaid** (default) | Sequence, ER, class, state, flowchart, component diagrams | Unlimited |
| **Excalidraw MCP** | Hero/overview diagrams — system context, high-level architecture | 2 per doc |
| **Python Diagrams** | Cloud architecture when AWS/GCP/Azure provider icons are needed | As needed |

### Mermaid Conventions

- Always initialize with: `%%{init: {'theme': 'neutral'}}%%`
- Add `<!-- diagram-tool: mermaid -->` comment above each Mermaid block
- Use consistent direction: `TB` for hierarchies, `LR` for flows

### Excalidraw Conventions

- Add `<!-- diagram-tool: excalidraw -->` comment above each Excalidraw reference
- Reserve for hero diagrams only — system context, top-level architecture
- Call `read_me` before first `create_view` in a session

### Python Diagrams Conventions

- Add `<!-- diagram-tool: python-diagrams -->` comment above each reference
- Only when cloud provider icons (AWS/GCP/Azure) add clarity
- Save scripts to `examples/`, output to `docs/diagrams/`
- Use SVG output format

### Color Coding (all tools)

| Color | Meaning |
|-------|---------|
| **Blue** (#4A90D9) | Core services / primary components |
| **Green** (#7CB342) | External services / third-party integrations |
| **Yellow** (#FDD835) | Data stores / databases / caches |
| **Red** (#E53935) | Security components / auth / encryption |
| **Grey** (#9E9E9E) | Infrastructure / networking / monitoring |

### File Organization

- Diagrams: `docs/diagrams/`
- Design documents: `docs/designs/`
- Python Diagrams scripts: `examples/`
