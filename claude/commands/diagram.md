Generate a diagram for: $ARGUMENTS

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
- Use color coding: Blue=core, Green=external, Yellow=data, Red=security, Grey=infra
- Wrap in a fenced code block with `mermaid` language tag

### Excalidraw MCP
- Call `read_me` first if this is the first diagram in the session
- Use `create_view` with well-structured elements
- Keep the layout clean — max 15 elements per diagram

### Python Diagrams
- Generate a complete Python script using the `diagrams` library
- Use appropriate provider nodes (aws, gcp, azure, onprem, etc.)
- Save the script to `examples/`
- Set output format to SVG

## Output

- Add `<!-- diagram-tool: mermaid|excalidraw|python-diagrams -->` above the diagram
- Save diagram files to `docs/diagrams/`
- Save Python scripts to `examples/`
- Describe what the diagram shows after generating it
