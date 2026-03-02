# LinkedIn Automation Skill

A comprehensive LinkedIn automation skill for OpenClaw that allows posting, commenting, analytics, and engagement tracking via headless Playwright browser.

## ⚠️ Disclaimer

**PERSONAL USE ONLY** - This skill is for personal productivity. Do NOT use for spam, mass outreach, or commercial services. Use responsibly per [LinkedIn's User Agreement](https://www.linkedin.com/legal/user-agreement).

## Installation

```bash
# Install dependencies (already done)
cd /root/.openclaw/workspace/skills/linkedin-automation
source venv/bin/activate
pip install playwright
playwright install chromium

# Create browser profile directory
mkdir -p ~/.config/chromium-linkedin
```

## Session Setup (HEADLESS SERVERS)

Since you're on a headless server (no display), use one of these methods:

### Method 1: Manual Cookie Export (RECOMMENDED)

1. **On your LOCAL machine** (with Chrome/Chromium):
   - Install "EditThisCookie" extension
   - Go to https://linkedin.com and login
   - Click EditThisCookie → Export → JSON
   - Copy the JSON content

2. **On this server:**
   ```bash
   # Create cookies file
   mkdir -p ~/.config/chromium-linkedin
   nano ~/.config/chromium-linkedin/cookies.json
   # Paste the JSON from EditThisCookie and save

   # Run setup script
   ./setup-linkedin-session.sh
   ```

### Method 2: Using Xvfb (Virtual Display)

```bash
# Install Xvfb
apt-get install -y xvfb

# Run interactive setup
xvfb-run :99 -s '-screen 0 1280x720x24' \
  LINKEDIN_HEADLESS=0 LINKEDIN_DEBUG=1 \
  python3 scripts/setup-interactive.py
```

### Method 3: Run Setup Script

```bash
# Quick setup helper
./setup-linkedin-session.sh
```

## Quick Start

```bash
# Set up virtual environment
cd /root/.openclaw/workspace/skills/linkedin-automation
source venv/bin/activate

# Check if session is valid (after setup)
./linkedin-quick.sh check-session

# Read your feed
python3 scripts/linkedin.py feed --count 5

# Create a post (ALWAYS get user approval first!)
python3 scripts/linkedin.py post --text "Your post content here"

# Comment on a post
python3 scripts/linkedin.py comment --url "https://linkedin.com/feed/update/..." --text "Great insight!"

# Get analytics
python3 scripts/linkedin.py analytics --count 10
```

## Features

### ✅ Implemented
- Feed reading
- Post creation (text + image)
- Commenting
- Session validation
- Analytics (basic)
- @Mentions support
- Image upload with editor handling
- Profile stats

### 🚧 Coming Soon
- Edit/delete comments
- Repost with thoughts
- Advanced analytics
- Like monitoring
- Activity scraping
- Content calendar auto-publishing

## Golden Rule

**NEVER post, comment, or edit without EXPLICIT user approval.**

Always show the user what will be posted and get confirmation first.

## Configuration

### Environment Variables

```bash
# Browser profile path (default: ~/.config/chromium-linkedin)
export LINKEDIN_BROWSER_PROFILE="/path/to/profile"

# Enable debug mode
export LINKEDIN_DEBUG=1

# Content calendar config
export CC_DATA_FILE="/tmp/cc-data.json"
export CC_WEBHOOK_PORT=8401
```

## Directory Structure

```
linkedin-automation/
├── SKILL.md                    # This file
├── README.md                   # Quick start guide
├── scripts/
│   ├── linkedin.py            # Main CLI
│   ├── cc-webhook.py          # Content calendar webhook
│   └── lib/
│       ├── browser.py         # Browser management
│       └── selectors.py       # LinkedIn DOM selectors
├── references/
│   ├── content-strategy.md    # Posting best practices
│   ├── engagement.md          # Engagement strategies
│   ├── content-calendar.md    # Auto-publishing setup
│   └── dom-patterns.md        # Troubleshooting guide
└── venv/                      # Python virtual environment
```

## Troubleshooting

### Session Expired
```bash
# Log in manually via browser
google-chrome --user-data-dir=~/.config/chromium-linkedin https://linkedin.com
```

### Selectors Broken
LinkedIn updates UI frequently. Check `references/dom-patterns.md` for troubleshooting steps.

### Debug Mode
```bash
export LINKEDIN_DEBUG=1
python3 scripts/linkedin.py check-session
# Screenshots saved to /tmp/linkedin_debug_*.png
```

## Rate Limits

| Action | Daily | Weekly |
|--------|-------|--------|
| Posts | 2-3 | 10-15 |
| Comments | 20-30 | — |
| Likes | 100 | — |
| Connection requests | 30 | 100 |

**⚠️ Exceeding these limits can trigger LinkedIn's spam filters.**

## Support

- **Documentation:** See `references/` folder
- **Issues:** LinkedIn UI changes → check `dom-patterns.md`
- **OpenClaw:** https://docs.openclaw.ai

## License

MIT License - Use responsibly and at your own risk.
