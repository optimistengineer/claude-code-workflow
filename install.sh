#!/usr/bin/env bash
set -euo pipefail

# ─── Claude Code Configuration Kit — First-Time Installer ───
# Copies repo config files into ~/.claude/ for Claude Code to pick up.
# Safe: never silently overwrites — always asks first.

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_HOME="$HOME/.claude"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}ℹ ${NC}$1"; }
ok()    { echo -e "${GREEN}✅ ${NC}$1"; }
warn()  { echo -e "${YELLOW}⚠️  ${NC}$1"; }
err()   { echo -e "${RED}❌ ${NC}$1"; }

# Prompt before overwriting. Usage: safe_copy <src> <dst>
safe_copy() {
  local src="$1" dst="$2"
  if [[ -f "$dst" ]]; then
    echo ""
    warn "File already exists: $dst"
    if diff -q "$src" "$dst" &>/dev/null; then
      ok "  Identical — skipping."
      return 0
    fi
    echo "  Diff (repo → existing):"
    diff --color=auto "$src" "$dst" || true
    echo ""
    read -rp "  Overwrite $dst? [y/N] " answer
    if [[ "$answer" != [yY] ]]; then
      info "  Skipped."
      return 0
    fi
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  ok "  Installed: $dst"
}

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   Claude Code Configuration Kit — Installer      ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# ── Step 1: Create directories ──
info "Creating directories..."
mkdir -p "$CLAUDE_HOME/commands"
ok "~/.claude/commands/ ready"

# ── Step 2: Copy CLAUDE.md (global instructions) ──
echo ""
info "Installing global instructions..."
safe_copy "$REPO_DIR/claude/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"

# ── Step 3: Copy slash commands ──
echo ""
info "Installing slash commands..."
for cmd_file in "$REPO_DIR"/claude/commands/*.md; do
  [[ -f "$cmd_file" ]] || continue
  name="$(basename "$cmd_file")"
  safe_copy "$cmd_file" "$CLAUDE_HOME/commands/$name"
done

# ── Step 4: Copy MCP servers config ──
echo ""
info "Installing MCP servers config..."
safe_copy "$REPO_DIR/mcp-servers.json" "$CLAUDE_HOME/.mcp.json"

# ── Step 5: Optional — install Python Diagrams ──
echo ""
read -rp "Install Python Diagrams library (pip3 install diagrams)? [y/N] " install_diagrams
if [[ "$install_diagrams" == [yY] ]]; then
  info "Installing diagrams..."
  pip3 install diagrams && ok "Python Diagrams installed." || err "Failed — install manually: pip3 install diagrams"
else
  info "Skipped Python Diagrams. Install later: pip3 install diagrams"
fi

# ── Done ──
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "Installation complete!"
echo ""
info "Installed files:"
echo "  ~/.claude/CLAUDE.md          — Global instructions"
echo "  ~/.claude/commands/*.md      — Slash commands (/hld, /lld, /diagram, /review)"
echo "  ~/.claude/.mcp.json          — MCP servers (Excalidraw)"
echo ""
info "Next: open any project and run 'claude' to start using the commands."
echo ""
