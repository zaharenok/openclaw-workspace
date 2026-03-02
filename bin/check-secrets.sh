#!/bin/bash
# Secrets Check Script
# Scans workspace for potential secrets/keys/tokens
# Only scans if files changed since last check

set -e

WORKSPACE="/home/node/.openclaw/workspace"
cd "$WORKSPACE"

# State file to track last check
STATE_FILE="$WORKSPACE/.secrets-check-state"

# Get list of tracked files (excluding gitignored)
TRACKED_FILES=$(git ls-files 2>/dev/null || true)

# Get current git state
CURRENT_STATE=$(echo "$TRACKED_FILES" | xargs ls -la 2>/dev/null | md5sum || echo "no-git")

# Load previous state
if [ -f "$STATE_FILE" ]; then
    PREV_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "")
else
    PREV_STATE=""
fi

# If nothing changed, skip check
if [ "$CURRENT_STATE" = "$PREV_STATE" ]; then
    # Silent exit - no changes
    exit 0
fi

# Patterns to search for (common secret indicators)
PATTERNS=(
    "password\s*=\s*['\"][^'\"]{8,}"  # password = "longstring"
    "api[_-]?key\s*=\s*['\"][^'\"]{20,}"  # api_key = "longstring"
    "secret\s*=\s*['\"][^'\"]{16,}"  # secret = "longstring"
    "token\s*=\s*['\"][^'\"]{20,}"  # token = "longstring"
    "sk-[a-zA-Z0-9]{32,}"  # OpenAI-style keys
    "ghp_[a-zA-Z0-9]{36}"  # GitHub tokens
    "AKIA[0-9A-Z]{16}"  # AWS keys
    "AIza[0-9A-Za-z\\-_]{35}"  # Google keys
    "xoxb-[0-9]{10,}-[0-9]{10,}-[a-zA-Z0-9]{24}"  # Slack bot tokens
)

# Directories to exclude
EXCLUDES=(
    "node_modules"
    ".git"
    "dist"
    "build"
    "coverage"
)

# Build exclude pattern
EXCLUDE_PATTERN=""
for dir in "${EXCLUDES[@]}"; do
    EXCLUDE_PATTERN="$EXCLUDE_PATTERN --exclude-dir=$dir"
done

echo "🔍 Secrets Check Started"
echo "========================"
echo ""

FOUND=0

# Search for each pattern
for pattern in "${PATTERNS[@]}"; do
    # Use grep to search, suppress errors, and exclude directories
    RESULTS=$(grep -rniE "$pattern" . $EXCLUDE_PATTERN 2>/dev/null || true)

    if [ -n "$RESULTS" ]; then
        echo "⚠️  Found potential secrets:"
        echo "$RESULTS"
        echo ""
        FOUND=1
    fi
done

# Check for common secret files
SECRET_FILES=(
    ".env"
    ".env.local"
    ".env.production"
    "secrets.json"
    "credentials.json"
    "config.secrets.json"
)

echo ""
echo "📁 Checking for secret files..."
for file in "${SECRET_FILES[@]}"; do
    if find . -name "$file" -not -path "*/node_modules/*" 2>/dev/null | grep -q .; then
        echo "⚠️  Found: $file"
        FOUND=1
    fi
done

echo ""
echo "========================"

if [ $FOUND -eq 0 ]; then
    echo "✅ No secrets detected"
    # Save current state
    echo "$CURRENT_STATE" > "$STATE_FILE"
else
    echo "❌ POTENTIAL SECRETS FOUND!"
    echo ""
    echo "⚠️  Action required:"
    echo "   1. Review the matches above"
    echo "   2. Remove secrets from committed files"
    echo "   3. Add sensitive files to .gitignore"
    echo "   4. Consider git history cleanup if needed"
    echo ""
    echo "💡 Tip: Use clean-secrets-from-history.sh if needed"
    # Don't save state if secrets found - want to check again next time
fi

exit $FOUND
