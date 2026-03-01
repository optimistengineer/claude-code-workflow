#!/usr/bin/env bash
set -euo pipefail

# ─── Claude Code Configuration Kit — Sync Script ───
# Pulls latest from git, diffs against ~/.claude/, and applies changes.
# Shows what's new, updated, or local-only.

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_HOME="$HOME/.claude"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
DIM='\033[2m'
NC='\033[0m'

info()  { echo -e "${BLUE}ℹ ${NC}$1"; }
ok()    { echo -e "${GREEN}✅ ${NC}$1"; }
warn()  { echo -e "${YELLOW}⚠️  ${NC}$1"; }
new()   { echo -e "${CYAN}✨ new!${NC}  $1"; }
upd()   { echo -e "${YELLOW}🔄 updated${NC} $1"; }
same()  { echo -e "${DIM}  ── same${NC}  $1"; }
local_only() { echo -e "${GREEN}📌 local-only${NC} $1"; }

# Sync a single file. Usage: sync_file <src> <dst> <label>
sync_file() {
  local src="$1" dst="$2" label="$3"

  if [[ ! -f "$dst" ]]; then
    new "$label"
    read -rp "    Install? [Y/n] " answer
    if [[ "$answer" == [nN] ]]; then
      info "    Skipped."
      return 0
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    ok "    Installed."
    return 0
  fi

  if diff -q "$src" "$dst" &>/dev/null; then
    same "$label"
    return 0
  fi

  upd "$label"
  diff --color=auto "$src" "$dst" || true
  echo ""
  read -rp "    Apply update? [Y/n] " answer
  if [[ "$answer" == [nN] ]]; then
    info "    Skipped."
    return 0
  fi
  cp "$src" "$dst"
  ok "    Updated."
}

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   Claude Code Configuration Kit — Sync           ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# ── Step 1: Git pull ──
info "Pulling latest changes..."
cd "$REPO_DIR"
git pull --ff-only 2>&1 | while read -r line; do echo "  $line"; done
echo ""

# ── Step 2: Sync CLAUDE.md ──
info "Checking global instructions..."
sync_file "$REPO_DIR/claude/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md" "CLAUDE.md"

# ── Step 3: Sync slash commands ──
echo ""
info "Checking slash commands..."

# Sync repo commands → ~/.claude/commands/
for cmd_file in "$REPO_DIR"/claude/commands/*.md; do
  [[ -f "$cmd_file" ]] || continue
  name="$(basename "$cmd_file")"
  sync_file "$cmd_file" "$CLAUDE_HOME/commands/$name" "$name"
done

# Report local-only commands (in ~/.claude/commands/ but not in repo)
if [[ -d "$CLAUDE_HOME/commands" ]]; then
  for local_file in "$CLAUDE_HOME"/commands/*.md; do
    [[ -f "$local_file" ]] || continue
    name="$(basename "$local_file")"
    if [[ ! -f "$REPO_DIR/claude/commands/$name" ]]; then
      local_only "$name"
    fi
  done
fi

# ── Step 4: Sync MCP config ──
echo ""
info "Checking MCP servers config..."
sync_file "$REPO_DIR/mcp-servers.json" "$CLAUDE_HOME/.mcp.json" ".mcp.json"

# ── Done ──
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "Sync complete!"
echo ""
