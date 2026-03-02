#!/bin/bash

# Quick fix for context overflow
WORKSPACE="$HOME/.openclaw/workspace"

echo "🔧 Quick Context Fix"
echo ""

# Show current state
echo "📊 Current workspace:"
echo "  Size: $(du -sh "$WORKSPACE" 2>/dev/null | cut -f1)"
echo "  Memory files: $(find "$WORKSPACE/memory" -name "*.md" 2>/dev/null | wc -l)"
echo ""

# Suggest actions
echo "💡 To fix 'prompt too large':"
echo "  1. Start /new session (clean slate)"
echo "  2. Run: cd ~/workspace/context-manager && ./quick-fix.sh"
echo ""

# Create summary
cat > "$WORKSPACE/CONTEXT_SUMMARY.md" << 'EOF'
# Context Summary

## Quick Fix Strategies

### Immediate Actions
1. **Start new session**: Type `/new` in Telegram
2. **Archive old work**: Move completed projects to `archive/`
3. **Clean memory**: Remove old daily notes

### Prevention
- Use `/new` every 50-100 messages
- Keep MEMORY.md focused
- Use date-specific memory files
- Enable context compaction

### For Large Tasks
- Break into smaller steps
- Use Plan mode (OpenCode)
- Process files individually
- Summarize as you go

## Current Projects

<!-- List active projects here -->

## Recent Context

<!-- Brief summary of recent work -->
EOF

echo "✅ Created: CONTEXT_SUMMARY.md"
echo ""
echo "Next: Start /new session for clean context!"
