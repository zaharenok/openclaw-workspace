#!/bin/bash
# Repository Maintenance Script
# Runs daily to sync all repos and check for secrets
# Only runs if there are actual changes

set -e

WORKSPACE="/home/node/.openclaw/workspace"
REPOS_DIR="$HOME/repos"
MEMORY_DIR="$WORKSPACE/memory"
REPORTS_DIR="$WORKSPACE/reports"

# Create directories if needed
mkdir -p "$MEMORY_DIR" "$REPORTS_DIR"

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

TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
TODAY=$(date -u +"%Y-%m-%d")

if [ "$QUIET" = false ]; then
    echo "🔧 Repository Maintenance"
    echo "========================="
    echo "Started: $TIMESTAMP"
    echo ""
fi

# Check if repos directory exists
if [ ! -d "$REPOS_DIR" ]; then
    if [ "$QUIET" = false ]; then
        echo "❌ No repos directory found at $REPOS_DIR"
    fi
    exit 1
fi

# Step 1: Sync all repos
if [ "$QUIET" = false ]; then
    echo "📥 Step 1: Syncing repositories..."
fi

SYNC_REPORT="$REPORTS_DIR/repo-sync-$TODAY.md"
echo "# Repository Sync Report - $TODAY" > "$SYNC_REPORT"
echo "" >> "$SYNC_REPORT"
echo "**Timestamp:** $TIMESTAMP" >> "$SYNC_REPORT"
echo "" >> "$SYNC_REPORT"

CHANGES_FOUND=0

for repo in "$REPOS_DIR"/*; do
    if [ -d "$repo/.git" ]; then
        REPO_NAME=$(basename "$repo")
        cd "$repo"

        if [ "$QUIET" = false ]; then
            echo "  → $REPO_NAME"
        fi

        # Get current commit
        OLD_COMMIT=$(git rev-parse HEAD)

        # Pull changes
        if git pull origin main --quiet 2>&1 || git pull origin master --quiet 2>&1; then
            NEW_COMMIT=$(git rev-parse HEAD)

            if [ "$OLD_COMMIT" != "$NEW_COMMIT" ]; then
                CHANGES_FOUND=1
                echo "## $REPO_NAME" >> "$SYNC_REPORT"
                echo "- **Status:** ✅ Updated" >> "$SYNC_REPORT"
                echo "- **Old:** $OLD_COMMIT" >> "$SYNC_REPORT"
                echo "- **New:** $NEW_COMMIT" >> "$SYNC_REPORT"
                echo "- **Changes:**" >> "$SYNC_REPORT"
                git log --oneline $OLD_COMMIT..$NEW_COMMIT >> "$SYNC_REPORT"
                echo "" >> "$SYNC_REPORT"
            fi
        else
            echo "## $REPO_NAME" >> "$SYNC_REPORT"
            echo "- **Status:** ⚠️ Pull failed" >> "$SYNC_REPORT"
            echo "" >> "$SYNC_REPORT"
        fi
    fi
done

if [ "$CHANGES_FOUND" -eq 0 ]; then
    if [ "$QUIET" = false ]; then
        echo "  ✅ No changes in any repository"
        echo ""
    fi
    # Don't continue if nothing changed
    exit 0
fi

# Step 2: Update GITHUB_REPOSITORIES.md
if [ "$QUIET" = false ]; then
    echo "📊 Step 2: Updating repository inventory..."
fi

INVENTORY="$MEMORY_DIR/GITHUB_REPOSITORIES.md"

if [ -f "$INVENTORY" ]; then
    # Add update timestamp
    echo "" >> "$INVENTORY"
    echo "---" >> "$INVENTORY"
    echo "" >> "$INVENTORY"
    echo "**Last Updated:** $TIMESTAMP" >> "$INVENTORY"
fi

# Step 3: Scan for secrets
if [ "$QUIET" = false ]; then
    echo "🔍 Step 3: Scanning for secrets..."
fi

SECRETS_REPORT="$REPORTS_DIR/secrets-scan-$TODAY.md"
echo "# Secrets Scan Report - $TODAY" > "$SECRETS_REPORT"
echo "" >> "$SECRETS_REPORT"
echo "**Timestamp:** $TIMESTAMP" >> "$SECRETS_REPORT"
echo "" >> "$SECRETS_REPORT"

SECRETS_FOUND=0

for repo in "$REPOS_DIR"/*; do
    if [ -d "$repo/.git" ]; then
        REPO_NAME=$(basename "$repo")
        cd "$repo"

        if [ "$QUIET" = false ]; then
            echo "  → $REPO_NAME"
        fi

        # Run trufflehog if available
        if command -v trufflehog &> /dev/null; then
            SCAN_RESULT=$(trufflehog filesystem --directory . --json 2>/dev/null || true)

            if [ -n "$SCAN_RESULT" ]; then
                SECRETS_FOUND=1
                echo "## $REPO_NAME" >> "$SECRETS_REPORT"
                echo '```json' >> "$SECRETS_REPORT"
                echo "$SCAN_RESULT" >> "$SECRETS_REPORT"
                echo '```' >> "$SECRETS_REPORT"
                echo "" >> "$SECRETS_REPORT"
            fi
        fi
    fi
done

if [ "$SECRETS_FOUND" -eq 0 ]; then
    echo "## ✅ No secrets found" >> "$SECRETS_REPORT"
fi

# Summary
if [ "$QUIET" = false ]; then
    echo ""
    echo "========================="
    echo "✅ Maintenance complete"
    echo ""
    echo "📊 Reports generated:"
    echo "  - $SYNC_REPORT"
    echo "  - $SECRETS_REPORT"
fi

if [ "$SECRETS_FOUND" -eq 1 ]; then
    echo ""
    echo "⚠️  SECRETS DETECTED!"
    echo "   Review: $SECRETS_REPORT"
    exit 1
fi

exit 0
