#!/bin/bash
# Smart Cron Runner
# Wrapper for cron tasks that checks for changes before running
# Usage: smart-cron-runner.sh <task-name> <script-path> [args...]

set -e

TASK_NAME=$1
shift
SCRIPT_PATH=$1
shift
SCRIPT_ARGS="$@"

WORKSPACE="/home/node/.openclaw/workspace"
STATE_DIR="$WORKSPACE/.cron-state"
STATE_FILE="$STATE_DIR/${TASK_NAME}-last-run"

# Create state directory
mkdir -p "$STATE_DIR"

# Get current git state
cd "$WORKSPACE"
CURRENT_STATE=$(git status --porcelain | md5sum || date +%s)

# Load previous state
if [ -f "$STATE_FILE" ]; then
    PREV_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "")
else
    PREV_STATE=""
fi

# Function to save state
save_state() {
    echo "$CURRENT_STATE" > "$STATE_FILE"
}

# Function to run task
run_task() {
    echo "🚀 Running task: $TASK_NAME"
    echo "===================="

    if bash "$SCRIPT_PATH" $SCRIPT_ARGS; then
        echo ""
        echo "✅ Task completed: $TASK_NAME"
        save_state
        return 0
    else
        echo ""
        echo "❌ Task failed: $TASK_NAME"
        # Don't save state on failure - want to retry
        return 1
    fi
}

# Check if changes occurred
if [ "$CURRENT_STATE" = "$PREV_STATE" ]; then
    # No changes - skip task
    echo "⏭️  Skipping $TASK_NAME (no changes)"
    exit 0
fi

# Changes detected - run task
run_task
exit $?
