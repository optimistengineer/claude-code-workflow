# Claude Code Configuration Kit

Portable Claude Code configuration with slash commands, design templates, and hybrid diagram strategy. Clone once, install, sync across machines.

## Repo → ~/.claude/ Mapping

```
claude-code-workflow/               ~/.claude/
│                                   │
├── claude/                         │
│   ├── CLAUDE.md          ──────►  ├── CLAUDE.md          (global instructions)
│   └── commands/                   ├── commands/
│       ├── hld.md         ──────►  │   ├── hld.md         (/hld command)
│       ├── lld.md         ──────►  │   ├── lld.md         (/lld command)
│       ├── onboard.md     ──────►  │   ├── onboard.md     (/onboard command)
│       ├── diagram.md     ──────►  │   ├── diagram.md     (/diagram command)
│       └── review.md      ──────►  │   └── review.md      (/review command)
│                                   │
├── mcp-servers.json       ──────►  └── .mcp.json          (MCP servers)
│
├── templates/                      (stays in repo)
│   ├── hld-template.md
│   └── lld-template.md
├── examples/                       (stays in repo)
│   └── cloud-architecture.py
└── docs/                           (stays in repo)
    ├── setup-guide.md
    └── how-it-works.md
```

## Quick Start

```bash
# 1. Clone
git clone <your-repo-url> ~/claude-code-workflow
cd ~/claude-code-workflow

# 2. Install
./install.sh

# 3. Done — open any project and use the commands
claude
```

## Sync Across Machines

```bash
# Machine A: edit config, push
git add . && git commit -m "add new command" && git push

# Machine B: pull and apply
cd ~/claude-code-workflow
./sync.sh
```

`sync.sh` pulls latest, diffs against your `~/.claude/`, and asks before overwriting. It flags new commands, updated files, and local-only commands.

## Slash Commands

| Command | What It Does |
|---------|-------------|
| `/hld <system>` | Generates a 10-section High-Level Design with diagrams |
| `/lld <module>` | Generates a 12-section Low-Level Design with API specs, DB schemas, state machines |
| `/onboard` | Generates a complete 22-section onboarding doc from scratch — no HLD/LLD needed. Covers everything: architecture, data model, API, state machines, events, error handling, NFRs, infra, security, setup, workflows, conventions, decisions, risks, gotchas |
| `/diagram <description>` | Generates a single diagram using the right tool (Mermaid/Excalidraw/Python Diagrams) |
| `/review <code or design>` | Reviews across 5 categories with prioritized action items |

## Hybrid Diagram Strategy

| Tool | Use For | Limit |
|------|---------|-------|
| **Mermaid** (default, ~80%) | Sequence, ER, class, state, flowchart, component | Unlimited |
| **Excalidraw MCP** | Hero/overview diagrams (system context, architecture) | 2 per doc |
| **Python Diagrams** | Cloud architecture with AWS/GCP/Azure icons | As needed |

Color coding: Blue=core, Green=external, Yellow=data, Red=security, Grey=infra.

## Adding a New Command

1. Create `claude/commands/my-command.md` with `$ARGUMENTS` placeholder
2. Push to the repo
3. Run `./sync.sh` on other machines to pick it up

Command files use `$ARGUMENTS` to receive user input (e.g., `/my-command build a REST API`).

## File Listing

| File | Purpose |
|------|---------|
| `install.sh` | First-time setup — copies config to `~/.claude/` |
| `sync.sh` | Pull + diff + apply updates to `~/.claude/` |
| `mcp-servers.json` | MCP server configuration (Excalidraw) |
| `claude/CLAUDE.md` | Global instructions (diagram strategy, color coding) |
| `claude/commands/hld.md` | /hld slash command |
| `claude/commands/lld.md` | /lld slash command |
| `claude/commands/onboard.md` | /onboard slash command |
| `claude/commands/diagram.md` | /diagram slash command |
| `claude/commands/review.md` | /review slash command |
| `templates/hld-template.md` | HLD template with pre-wired diagrams |
| `templates/lld-template.md` | LLD template with API specs, DB design, state machines |
| `templates/onboard-template.md` | Onboarding doc template (17 sections) |
| `examples/cloud-architecture.py` | Python Diagrams AWS architecture example |
| `docs/setup-guide.md` | Complete setup walkthrough for beginners |
| `docs/how-it-works.md` | How Claude Code config loading works |

## Documentation

- **[Setup Guide](docs/setup-guide.md)** — Step-by-step setup for beginners
- **[How It Works](docs/how-it-works.md)** — Config loading order, sync workflow, precedence rules
