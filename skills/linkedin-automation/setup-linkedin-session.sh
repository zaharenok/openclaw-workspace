#!/bin/bash
# LinkedIn Session Setup Script
# For headless servers without display

set -e

SKILL_DIR="/root/.openclaw/workspace/skills/linkedin-automation"
PROFILE_DIR="$HOME/.config/chromium-linkedin"
STATE_FILE="$PROFILE_DIR/storage_state.json"

echo "🔧 LinkedIn Session Setup for Headless Environment"
echo "================================================"
echo ""

# Create profile directory
mkdir -p "$PROFILE_DIR"

# Check if state already exists
if [ -f "$STATE_FILE" ]; then
    echo "✅ Session state already exists at: $STATE_FILE"
    echo ""
    read -p "Do you want to re-authenticate? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "✅ Keeping existing session. Run 'check-session' to verify."
        exit 0
    fi
    mv "$STATE_FILE" "${STATE_FILE}.backup.$(date +%s)"
    echo "📦 Backed up old session"
fi

echo ""
echo "📋 Setup Instructions:"
echo "----------------------"
echo "Since you're on a headless server, choose one of these methods:"
echo ""
echo "Method 1: Manual Cookie Export (RECOMMENDED)"
echo "  1. On your LOCAL machine with Chrome/Chromium:"
echo "     - Install 'EditThisCookie' extension"
echo "     - Go to https://linkedin.com"
echo "     - Login to LinkedIn"
echo "     - Click EditThisCookie icon → Export → JSON"
echo "  2. Copy the JSON and create: $PROFILE_DIR/cookies.json"
echo "  3. Run this script again"
echo ""
echo "Method 2: Using Playwright in Debug Mode"
echo "  Requires Xvfb (virtual display):"
echo ""
echo "  # Install Xvfb"
echo "  apt-get install -y xvfb"
echo ""
echo "  # Run setup with virtual display"
echo "  xvfb-run :99 -s '-screen 0 1280x720x24' \\"
echo "    LINKEDIN_HEADLESS=0 LINKEDIN_DEBUG=1 \\"
echo "    python3 $SKILL_DIR/scripts/setup-interactive.py"
echo ""

# Check if cookies.json exists
if [ -f "$PROFILE_DIR/cookies.json" ]; then
    echo ""
    echo "🍪 Found cookies.json! Creating session..."
    cd "$SKILL_DIR"
    source venv/bin/activate

    python3 -c "
from pathlib import Path
import json

profile_dir = Path('$PROFILE_DIR')
cookies_file = profile_dir / 'cookies.json'
state_file = profile_dir / 'storage_state.json'

# Load cookies
with open(cookies_file, 'r') as f:
    cookies = json.load(f)

# Create storage state
storage_state = {
    'cookies': cookies,
    'origins': []
}

# Save state
with open(state_file, 'w') as f:
    json.dump(storage_state, f, indent=2)

print('✅ Session created from cookies!')
print(f'📁 Saved to: {state_file}')
"

    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Setup complete! Test your session:"
        echo "   ./linkedin-quick.sh check-session"
    fi
else
    echo ""
    echo "❌ No cookies.json found. Please use Method 1 to export cookies."
    echo ""
    echo "💡 Quick tip: If you have access to a machine with display, you can:"
    echo "   1. Login to LinkedIn there"
    echo "   2. Export cookies via EditThisCookie extension"
    echo "   3. Upload cookies.json to $PROFILE_DIR/"
    echo "   4. Run this script again"
fi

echo ""
echo "📚 Documentation:"
echo "   README.md - Quick start guide"
echo "   references/engagement.md - Rate limits & best practices"
