#!/usr/bin/env python3
"""Browser management for LinkedIn automation."""

import os
import json
from pathlib import Path
from playwright.sync_api import sync_playwright, Browser, Page, BrowserContext

# Default browser profile path
DEFAULT_PROFILE = os.path.expanduser("~/.config/chromium-linkedin")
PROFILE_PATH = os.getenv("LINKEDIN_BROWSER_PROFILE", DEFAULT_PROFILE)

# Debug mode
DEBUG = os.getenv("LINKEDIN_DEBUG", "0") == "1"

# Headless mode (default: True for servers without display)
# Override with LINKEDIN_HEADLESS=0 for visible browser (requires X11)
HEADLESS = os.getenv("LINKEDIN_HEADLESS", "1") == "1"

# Screenshot path for debugging
DEBUG_DIR = "/tmp"


def get_browser_context(p: sync_playwright) -> tuple[Browser, BrowserContext, Page]:
    """Launch browser with persistent context."""

    # Determine headless mode
    # Debug mode ALWAYS shows browser (requires DISPLAY)
    # Production mode uses HEADLESS env var or defaults to headless on servers
    if DEBUG:
        # Debug mode - show browser (requires X11 or fails)
        use_headless = False
    else:
        # Production mode - use HEADLESS env var or default
        use_headless = not os.getenv("LINKEDIN_HEADLESS", "1") == "0"

    # Launch options
    launch_options = {
        "headless": use_headless,
    }

    # Add args for running as root
    if os.geteuid() == 0:
        launch_options["args"] = ["--no-sandbox", "--disable-setuid-sandbox"]

    browser = p.chromium.launch(**launch_options)

    # Create persistent context
    state_file = Path(PROFILE_PATH) / "storage_state.json"

    context_options = {
        "viewport": {"width": 1280, "height": 720},
        "locale": "en-US",
        "timezone_id": "Europe/Vienna",
        "user_agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }

    # Load existing session if available
    if state_file.exists():
        # Load cookies from file
        with open(state_file, 'r') as f:
            state = json.load(f)

        # Create context without storage state (avoids validation issues)
        context = browser.new_context(**context_options)

        # Clean all cookies FIRST
        clean_cookies = []
        for cookie in state.get('cookies', []):
            clean_cookie = {
                'name': cookie['name'],
                'value': cookie['value'],
                'domain': cookie.get('domain'),
                'path': cookie.get('path', '/'),
                'httpOnly': cookie.get('httpOnly', False),
                'secure': cookie.get('secure', True)
            }
            # Add expiration if present
            if 'expirationDate' in cookie:
                clean_cookie['expires'] = cookie['expirationDate']

            clean_cookies.append(clean_cookie)

        # Add ALL cookies at once (add_cookies requires array)
        context.add_cookies(clean_cookies)
    else:
        # No existing session - create fresh context
        context = browser.new_context(**context_options)

    page = context.new_page()

    # Set default timeout
    page.set_default_timeout(30000)

    return browser, context, page


def save_storage_state(context: BrowserContext):
    """Save browser state for persistence."""
    state_path = Path(PROFILE_PATH) / "storage_state.json"
    state_path.parent.mkdir(parents=True, exist_ok=True)
    context.storage_state(path=str(state_path))


def take_debug_screenshot(page: Page, name: str):
    """Save debug screenshot if debug mode enabled."""
    if DEBUG:
        from datetime import datetime
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        path = f"{DEBUG_DIR}/linkedin_debug_{name}_{timestamp}.png"
        page.screenshot(path=path)
        print(f"Debug screenshot saved: {path}")


def get_cookies_from_browser() -> dict:
    """Extract LinkedIn cookies from your local browser."""
    # This is a helper for manual setup
    # Users can export cookies from their browser using extensions like "EditThisCookie"
    cookie_file = Path(PROFILE_PATH) / "cookies.json"

    if cookie_file.exists():
        with open(cookie_file, "r") as f:
            return json.load(f)
    return {}


def import_cookies_to_playwright(cookies: list):
    """Import cookies to create a logged-in session."""
    from playwright.sync_api import sync_playwright

    with sync_playwright() as p:
        browser, context, page = get_browser_context(p)

        # Add cookies
        context.add_cookies(cookies)

        # Save state
        save_storage_state(context)

        browser.close()
        return True
