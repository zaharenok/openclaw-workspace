#!/bin/bash
# GitHub Backup Script
# Backs up workspace changes to GitHub
# Only runs if there are actual changes to commit

set -e

WORKSPACE="/home/node/.openclaw/workspace"
cd "$WORKSPACE"

# Quiet mode - only output if there are changes
QUIET=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --quiet|-q)
            QUIET=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Check if git is initialized
if [ ! -d ".git" ]; then
    if [ "$QUIET" = false ]; then
        echo "❌ Error: Not a git repository"
    fi
    exit 1
fi

# Check for changes (staged and unstaged)
if git diff-index --quiet HEAD -- 2>/dev/null; then
    # No changes at all
    if [ "$QUIET" = false ]; then
        echo "✅ No changes to backup"
    fi
    exit 0
fi

# There are changes - show what's happening
if [ "$QUIET" = false ]; then
    TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    echo "🔄 Starting backup at $TIMESTAMP"
    echo "========================================"
fi

# Pull latest changes first
if [ "$QUIET" = false ]; then
    echo "📥 Pulling latest changes..."
fi

if git pull origin main --quiet 2>&1; then
    if [ "$QUIET" = false ]; then
        echo "✅ Pull successful"
    fi
else
    if [ "$QUIET" = false ]; then
        echo "⚠️  Pull failed, continuing..."
    fi
fi

# Show what changed
if [ "$QUIET" = false ]; then
    echo ""
    echo "📝 Changes detected:"
    git status --short
fi

# Check if there are memory files specifically
MEMORY_CHANGED=$(git diff --name-only | grep -E "^memory/" || true)
if [ -n "$MEMORY_CHANGED" ] && [ "$QUIET" = false ]; then
    echo ""
    echo "📝 Adding memory files..."
    echo "$MEMORY_CHANGED"
fi

# Add all changes
git add -A

# Get list of changed files
CHANGED=$(git diff --cached --name-only | wc -l)

if [ "$CHANGED" -eq 0 ]; then
    if [ "$QUIET" = false ]; then
        echo "✅ No memory files changed. Nothing to commit."
    fi
    exit 0
fi

# Commit with timestamp
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
COMMIT_MSG="Update: $TIMESTAMP"

if [ "$QUIET" = false ]; then
    echo ""
    echo "💾 Committing $CHANGED file(s)..."
    git commit -m "$COMMIT_MSG"
else
    git commit -m "$COMMIT_MSG" --quiet
fi

# Push to origin
if [ "$QUIET" = false ]; then
    echo ""
    echo "🚀 Pushing to GitHub..."
fi

if git push origin main --quiet 2>&1; then
    if [ "$QUIET" = false ]; then
        echo ""
        echo "========================================"
        echo "✅ Backup complete: $CHANGED file(s) pushed"
    fi
else
    if [ "$QUIET" = false ]; then
        echo "❌ Push failed"
    fi
    exit 1
fi
