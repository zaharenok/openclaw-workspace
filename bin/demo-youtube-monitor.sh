#!/bin/bash
#
# Demo script for Telegram YouTube Monitor
# Shows how to integrate with OpenClaw sessions
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONITOR_SCRIPT="$SCRIPT_DIR/telegram-youtube-monitor.sh"

echo "🎬 Telegram YouTube Monitor Demo"
echo "================================"
echo ""

# Test with a sample channel (you can change this)
TEST_CHANNEL="@telegram"  # Official Telegram channel
LIMIT=10

echo "📊 Configuration:"
echo "  Channel: $TEST_CHANNEL"
echo "  Limit: $LIMIT messages"
echo ""

echo "🔍 Running monitor..."
echo "---"
"$MONITOR_SCRIPT" "$TEST_CHANNEL" "$LIMIT"
echo "---"
echo ""

echo "✅ Demo complete!"
echo ""
echo "Next steps:"
echo "  1. Replace $TEST_CHANNEL with your target channel"
echo "  2. Adjust message limit as needed"
echo "  3. Add to cron or HEARTBEAT.md for automation"
echo ""
echo "Documentation:"
echo "  - Quick commands: ~/workspace/bin/youtube-monitor-commands.md"
echo "  - Full docs: ~/workspace/docs/telegram-youtube-monitor.md"
