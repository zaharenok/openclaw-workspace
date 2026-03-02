#!/bin/bash

# Context Manager - Fix "prompt too large" errors
# Usage: ./fix-context.sh [analyze|compress|clean]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$HOME/.openclaw/workspace"

# Colors
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
NC='\\033[0m' # No Color

echo "🔧 Context Manager"
echo ""

case "${1:-help}" in
  analyze)
    echo "📊 Analyzing context size..."
    
    # Check session context
    if [ -f "$WORKSPACE/memory/context.json" ]; then
      node "$SCRIPT_DIR/context-manager.js" analyze "$WORKSPACE/memory/context.json"
    else
      echo -e "${YELLOW}⚠ No context file found at $WORKSPACE/memory/context.json${NC}"
      echo "Creating sample context..."
      mkdir -p "$WORKSPACE/memory"
      echo '{"messages":[],"system":""}' > "$WORKSPACE/memory/context.json"
    fi
    ;;

  compress)
    echo "🗜️ Compressing context..."
    echo "This will summarize old messages to reduce token count."
    echo ""
    echo "Strategies:"
    echo "  1. Remove consecutive duplicates"
    echo "  2. Summarize messages older than N turns"
    echo "  3. Optimize system prompt"
    echo ""
    echo -e "${YELLOW}⚠ Make sure to backup important context first!${NC}"
    ;;

  clean)
    echo "🧹 Cleaning up old context..."
    
    # Clean old memory files
    find "$WORKSPACE/memory" -name "*.md" -mtime +30 -exec rm -v {} \\;
    
    # Compress old logs
    find "$WORKSPACE" -name "*.log" -mtime +7 -exec gzip -v {} \\;
    
    echo -e "${GREEN}✅ Cleanup complete!${NC}"
    ;;

  stats)
    echo "📈 Context stats:"
    
    # Count memory files
    local mem_count=$(find "$WORKSPACE/memory" -name "*.md" 2>/dev/null | wc -l)
    echo "  Memory files: $mem_count"
    
    # Check skills
    local skill_count=$(find "$WORKSPACE/skills" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l)
    echo "  Skills: $skill_count"
    
    # Total workspace size
    local size=$(du -sh "$WORKSPACE" 2>/dev/null | cut -f1)
    echo "  Total size: $size"
    ;;

  help|*)
    cat << EOF
Context Manager - Fix "prompt too large" errors

Usage: ./fix-context.sh [command]

Commands:
  analyze   Analyze current context size and token usage
  compress  Compress context by summarizing old messages
  clean     Remove old memory files and compress logs
  stats     Show workspace statistics

Examples:
  ./fix-context.sh analyze
  ./fix-context.sh compress
  ./fix-context.sh clean

Strategies to avoid overflow:
  1. Use /new to start fresh sessions regularly
  2. Keep memory files focused and concise
  3. Archive old projects instead of keeping in main workspace
  4. Use chunking for large requests
  5. Enable context compaction in OpenClaw settings

For OpenCode overflow:
  - Use Plan mode to review before implementing
  - Break features into smaller steps
  - /init creates AGENTS.md - keeps context focused
EOF
    ;;
esac

echo ""
