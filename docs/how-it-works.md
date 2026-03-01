# How It Works

Understanding Claude Code's configuration system and how this kit leverages it.

---

## Claude Code Config Loading Order

Claude Code loads configuration in layers, with later layers overriding earlier ones:

```
1. Built-in defaults (Claude Code internal)
        ↓
2. Global config: ~/.claude/CLAUDE.md
        ↓
3. Global commands: ~/.claude/commands/*.md
        ↓
4. Global MCP servers: ~/.claude/.mcp.json
        ↓
5. Project config: <project>/.claude/CLAUDE.md   ← extends global (both active)
        ↓
6. Project commands: <project>/.claude/commands/  ← merged with global
        ↓
7. Project MCP servers: <project>/mcp-servers.json
```

### Precedence Rules

| Scope | Config File | Commands | MCP Servers |
|-------|------------|----------|-------------|
| **Global** (`~/.claude/`) | Base instructions | Available everywhere | Available everywhere |
| **Project** (`<project>/.claude/`) | Extends global (both active) | Merged (project wins on conflict) | Merged with global |

Key behaviors:
- **CLAUDE.md**: Project-level *adds to* global instructions — both global and project CLAUDE.md are active simultaneously, they do not override each other
- **Commands**: If the same command name exists in both global and project, project wins
- **MCP servers**: Merged — both global and project servers are available

---

## How install.sh Maps Files

The installer copies files from this repo into `~/.claude/`:

```
claude-code-workflow/                 ~/.claude/
├── claude/                    →
│   ├── CLAUDE.md              →      CLAUDE.md
│   └── commands/              →      commands/
│       ├── hld.md             →          hld.md
│       ├── lld.md             →          lld.md
│       ├── diagram.md         →          diagram.md
│       └── review.md          →          review.md
├── mcp-servers.json           →      .mcp.json
│
├── templates/                        (stays in repo — referenced by commands)
├── examples/                         (stays in repo — reference scripts)
└── docs/                             (stays in repo — documentation)
```

Files in `templates/`, `examples/`, and `docs/` are **not** copied to `~/.claude/`. They stay in the repo and are referenced by the slash commands when you run them from within this project directory.

---

## Multi-Machine Sync Workflow

```
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│  Machine A   │       │    GitHub     │       │  Machine B   │
│              │       │              │       │              │
│ 1. Edit      │       │              │       │              │
│    config    │       │              │       │              │
│              │       │              │       │              │
│ 2. git push ─┼──────►│  Repository  │       │              │
│              │       │              │       │              │
│              │       │              │◄──────┼─ 3. sync.sh  │
│              │       │              │       │    (pulls +   │
│              │       │              │       │     diffs +   │
│              │       │              │       │     copies)   │
│              │       │              │       │              │
│   ~/.claude/ │       │              │       │   ~/.claude/ │
│   (updated)  │       │              │       │   (updated)  │
└──────────────┘       └──────────────┘       └──────────────┘
```

### Sync Workflow Steps

1. **Edit** — Modify config/commands in the repo on Machine A
2. **Push** — `git add . && git commit -m "update" && git push`
3. **Sync** — On Machine B, run `./sync.sh` which:
   - Runs `git pull` to get latest changes
   - Diffs each repo file against its `~/.claude/` counterpart
   - Shows new commands as "new!" and changed ones as "updated"
   - Reports commands in `~/.claude/commands/` that aren't in the repo (local-only)
   - Asks before overwriting each changed file

### Adding a New Command

1. Create `claude/commands/my-command.md` in the repo
2. Push to GitHub
3. On other machines: run `./sync.sh` — it will detect the new command and offer to install it

### Modifying Global Instructions

1. Edit `claude/CLAUDE.md` in the repo
2. Push to GitHub
3. On other machines: run `./sync.sh` — it will show the diff and ask to apply

---

## Why This Structure?

| Design Choice | Reason |
|--------------|--------|
| Repo ≠ `~/.claude/` | Keeps docs, templates, examples separate from config |
| `install.sh` for first time | Safe setup with confirmation prompts |
| `sync.sh` for updates | Shows diffs, never silently overwrites |
| Templates stay in repo | Commands reference them — works when running from repo dir |
| MCP config as `.mcp.json` | Claude Code's expected filename for global MCP servers |
