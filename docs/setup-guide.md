# Setup Guide

Step-by-step instructions for setting up the Claude Code Configuration Kit.

---

## Prerequisites

| Requirement | Why | Check |
|-------------|-----|-------|
| **Claude Code CLI** | The CLI tool this kit configures | `claude --version` |
| **Git** | Clone and sync the repo | `git --version` |
| **Bash 4+** | Scripts use bash features | `bash --version` |
| **Python 3.8+** (optional) | For Python Diagrams cloud architecture | `python3 --version` |

---

## What Each File Does

| File | Purpose | Installed To |
|------|---------|-------------|
| `claude/CLAUDE.md` | Global instructions for Claude Code (diagram strategy, color coding) | `~/.claude/CLAUDE.md` |
| `claude/commands/*.md` | Slash commands: /hld, /lld, /diagram, /review | `~/.claude/commands/` |
| `mcp-servers.json` | MCP server config (Excalidraw) | `~/.claude/.mcp.json` |
| `templates/*.md` | Design doc templates (referenced by commands) | Stays in repo |
| `examples/*.py` | Example diagram scripts | Stays in repo |

---

## Where is ~/.claude/?

The `~/.claude/` directory is Claude Code's **global configuration directory**. It lives in your home folder:

| OS | Path |
|----|------|
| macOS | `/Users/<username>/.claude/` |
| Linux | `/home/<username>/.claude/` |

Claude Code reads from this directory on every session start. Files here apply to **all projects**.

---

## 7-Step Setup

### Step 1: Clone the repository

```bash
git clone <your-repo-url> ~/claude-code-workflow
cd ~/claude-code-workflow
```

### Step 2: Review the config files

Look through `claude/CLAUDE.md` and the command files in `claude/commands/` to understand what will be installed.

### Step 3: Run the installer

```bash
./install.sh
```

The installer will:
- Create `~/.claude/commands/` if it doesn't exist
- Copy `CLAUDE.md` to `~/.claude/CLAUDE.md`
- Copy all slash commands to `~/.claude/commands/`
- Copy MCP config to `~/.claude/.mcp.json`
- Optionally install Python Diagrams

It **asks before overwriting** any existing file.

### Step 4: Verify the installation

```bash
# Check files exist
ls -la ~/.claude/CLAUDE.md
ls -la ~/.claude/commands/
ls -la ~/.claude/.mcp.json
```

### Step 5: Test in Claude Code

Open any project and start Claude Code:

```bash
cd ~/some-project
claude
```

Try a command:
```
/diagram a sequence diagram for user authentication
```

### Step 6: (Optional) Install Python Diagrams

If you skipped this during install:

```bash
pip3 install diagrams
```

Test with the included example:

```bash
cd ~/claude-code-workflow
python3 examples/cloud-architecture.py
```

### Step 7: Set up on additional machines

On your other machines:

```bash
git clone <your-repo-url> ~/claude-code-workflow
cd ~/claude-code-workflow
./install.sh
```

---

## Verification Script

Quick check that everything is installed correctly:

```bash
echo "=== Claude Code Config Verification ==="
echo ""
echo "CLAUDE.md:"
[ -f ~/.claude/CLAUDE.md ] && echo "  ✅ Found" || echo "  ❌ Missing"
echo ""
echo "Commands:"
for cmd in hld lld onboard diagram review; do
  [ -f ~/.claude/commands/${cmd}.md ] && echo "  ✅ /${cmd}" || echo "  ❌ /${cmd} missing"
done
echo ""
echo "MCP config:"
[ -f ~/.claude/.mcp.json ] && echo "  ✅ Found" || echo "  ❌ Missing"
echo ""
echo "Python Diagrams:"
python3 -c "import diagrams" 2>/dev/null && echo "  ✅ Installed" || echo "  ⚠️  Not installed (optional)"
```

---

## Troubleshooting

### Commands not showing up in Claude Code

- Ensure files are in `~/.claude/commands/` (not `~/.claude/claude/commands/`)
- File extension must be `.md`
- Restart Claude Code after installing

### Excalidraw MCP not connecting

- Check `~/.claude/.mcp.json` exists and has the correct URL
- Ensure you have internet connectivity
- Restart Claude Code

### Python Diagrams errors

- Install Graphviz: `brew install graphviz` (macOS) or `apt install graphviz` (Linux)
- Graphviz is required by the `diagrams` library for rendering

### Permission denied on install.sh

```bash
chmod +x install.sh sync.sh
```
