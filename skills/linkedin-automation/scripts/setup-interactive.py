#!/usr/bin/env python3
"""
Interactive LinkedIn setup using Playwright.
Run with Xvfb on headless servers:
  xvfb-run :99 -s '-screen 0 1280x720x24' LINKEDIN_HEADLESS=0 LINKEDIN_DEBUG=1 python3 setup-interactive.py
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from playwright.sync_api import sync_playwright
from lib.browser import get_browser_context, save_storage_state, PROFILE_PATH


def main():
    """Interactive LinkedIn login setup."""

    print("🔐 LinkedIn Interactive Login Setup")
    print("=" * 40)
    print()

    with sync_playwright() as p:
        print("🚀 Launching browser...")
        browser, context, page = get_browser_context(p)

        # Navigate to LinkedIn
        print("📍 Navigating to LinkedIn...")
        page.goto("https://linkedin.com", wait_until="networkidle")

        # Check if already logged in
        try:
            page.wait_for_selector("a[data-control-name='view_profile']", timeout=5000)
            print("✅ You're already logged in!")
        except:
            print()
            print("⚠️  Please log in to LinkedIn in the browser window.")
            print("⏳ Waiting for login (this will wait until you're logged in)...")
            print()

            # Wait for login completion
            try:
                page.wait_for_selector("a[data-control-name='view_profile']", timeout=300000)  # 5 min
                print("✅ Login detected!")
            except:
                print("❌ Login timeout or failed")
                browser.close()
                return

        # Save session state
        print()
        print("💾 Saving session state...")
        save_storage_state(context)

        state_path = Path(PROFILE_PATH) / "storage_state.json"
        print(f"✅ Session saved to: {state_path}")
        print()

        # Verify session
        print("🧪 Verifying session...")
        page.goto("https://linkedin.com/feed", wait_until="networkidle")

        try:
            page.wait_for_selector("div.feed-shared-update-v2", timeout=5000)
            print("✅ Session verified - feed loaded successfully!")
        except:
            print("⚠️  Feed not loaded - you may need to complete additional verification")

        print()
        print("🎉 Setup complete!")
        print("You can now use the LinkedIn automation skill:")
        print("  ./linkedin-quick.sh check-session")

        # Close browser
        browser.close()


if __name__ == "__main__":
    main()
