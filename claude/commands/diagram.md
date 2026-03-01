Generate a diagram for: $ARGUMENTS

If the request references existing code or systems, read the relevant files first to ensure accuracy.

## Tool Selection (Hybrid Strategy)

Pick the right tool based on the diagram type:

| Diagram Type | Tool |
|---|---|
| Sequence, ER, class, state, flowchart, component | **Mermaid** |
| System context, high-level architecture overview | **Excalidraw MCP** |
| Cloud architecture with AWS/GCP/Azure icons | **Python Diagrams** |

If the type is ambiguous, default to **Mermaid**.

## Instructions per Tool

### Mermaid
- Start with `%%{init: {'theme': 'neutral'}}%%`
- Use color coding: Blue (#4A90D9)=core, Green (#7CB342)=external, Yellow (#FDD835)=data, Red (#E53935)=security, Grey (#9E9E9E)=infra
- Wrap in a fenced code block with `mermaid` language tag
- Use `TB` for hierarchies, `LR` for flows

### Excalidraw MCP
- Call `read_me` first if this is the first diagram in the session
- Use `create_view` with well-structured elements
- Keep the layout clean — max 15 elements per diagram

### Python Diagrams
- Generate a complete Python script using the `diagrams` library
- Use appropriate provider nodes (aws, gcp, azure, onprem, etc.)
- Save the script to `examples/`
- Set output format to SVG
- Requires: `pip3 install diagrams` and Graphviz installed

## Output

- Create `docs/diagrams/` directory if it doesn't exist
- Add `<!-- diagram-tool: mermaid|excalidraw|python-diagrams -->` above the diagram
- Save diagram files to `docs/diagrams/`
- Save Python scripts to `examples/`
- Describe what the diagram shows after generating it
