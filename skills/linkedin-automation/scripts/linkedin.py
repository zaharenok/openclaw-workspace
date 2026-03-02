#!/usr/bin/env python3
"""
LinkedIn Automation CLI
Automate LinkedIn interactions via headless Playwright browser.
"""

import sys
import json
import argparse
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional

# Add lib to path
sys.path.insert(0, str(Path(__file__).parent))

from playwright.sync_api import sync_playwright, Page, TimeoutError as PlaywrightTimeout
from lib.browser import get_browser_context, save_storage_state, take_debug_screenshot, DEBUG
from lib.selectors import SELECTORS, URLS


class LinkedInAutomation:
    """Main automation class for LinkedIn."""
    
    def __init__(self):
        self.p = sync_playwright().start()
        self.browser, self.context, self.page = get_browser_context(self.p)
        self.base_url = URLS["base"]
        self.result = {}
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        save_storage_state(self.context)
        self.context.close()
        self.browser.close()
        self.p.stop()
        
        # Print result as JSON
        if self.result:
            print(json.dumps(self.result, indent=2, ensure_ascii=False))
    
    def navigate(self, url: str):
        """Navigate to URL."""
        self.page.goto(url, wait_until="networkidle")
        take_debug_screenshot(self.page, "navigate")
    
    def wait_for_selector(self, selector: str, timeout: int = 5000):
        """Wait for selector to appear."""
        self.page.wait_for_selector(selector, timeout=timeout)
    
    def check_session(self) -> dict:
        """Check if LinkedIn session is valid."""
        self.navigate(URLS["feed"])
        
        try:
            self.wait_for_selector(SELECTORS["logged_in"], timeout=5000)
            return {
                "success": True,
                "message": "Session is valid",
                "timestamp": datetime.now().isoformat()
            }
        except PlaywrightTimeout:
            return {
                "success": False,
                "message": "Session expired or not logged in",
                "timestamp": datetime.now().isoformat()
            }
    
    def read_feed(self, count: int = 5) -> dict:
        """Read LinkedIn feed posts."""
        self.navigate(URLS["feed"])
        
        posts = []
        post_elements = self.page.query_selector_all(SELECTORS["feed_post"])
        
        for i, post in enumerate(post_elements[:count]):
            try:
                author = post.query_selector(SELECTORS["post_author"])
                text = post.query_selector(SELECTORS["post_text"])
                link = post.query_selector(SELECTORS["post_link"])
                
                posts.append({
                    "author": author.inner_text() if author else "Unknown",
                    "text": text.inner_text() if text else "",
                    "url": link.get_attribute("href") if link else "",
                    "scraped_at": datetime.now().isoformat()
                })
            except Exception as e:
                if DEBUG:
                    print(f"Error parsing post {i}: {e}")
        
        self.result = {
            "success": True,
            "posts": posts,
            "count": len(posts)
        }
        return self.result
    
    def create_post(self, text: str, image: Optional[str] = None) -> dict:
        """Create a new LinkedIn post."""
        self.navigate(URLS["feed"])
        
        # Click post button
        self.wait_for_selector(SELECTORS["post_button"])
        self.page.click(SELECTORS["post_button"])
        
        # Wait for editor
        self.wait_for_selector(SELECTORS["post_textarea"])
        
        # Type post text
        self.page.fill(SELECTORS["post_textarea"], text)
        
        # Add image if provided
        if image:
            self.page.click(SELECTORS["post_image_button"])
            
            # Wait for file input
            file_input = self.page.wait_for_selector(SELECTORS["post_image_input"])
            file_input.set_input_files(image)
            
            # Wait for image editor modal
            self.wait_for_selector(SELECTORS["image_editor_modal"], timeout=10000)
            
            # Click done to close image editor
            self.page.click(SELECTORS["image_editor_done"])
            
            # Wait for modal to close
            self.page.wait_for_selector(
                SELECTORS["image_editor_modal"],
                state="hidden",
                timeout=5000
            )
        
        # Submit post
        self.page.click(SELECTORS["post_submit"])
        
        # Wait for post to appear
        try:
            self.page.wait_for_selector("div.feed-shared-update-v2", timeout=10000)
            self.result = {
                "success": True,
                "message": "Post created successfully",
                "text": text,
                "has_image": image is not None,
                "timestamp": datetime.now().isoformat()
            }
        except PlaywrightTimeout:
            self.result = {
                "success": False,
                "message": "Failed to create post (timeout)",
                "text": text,
                "timestamp": datetime.now().isoformat()
            }
        
        return self.result
    
    def add_comment(self, url: str, text: str) -> dict:
        """Add a comment to a LinkedIn post."""
        self.navigate(url)
        
        # Click comment button
        try:
            self.wait_for_selector(SELECTORS["comment_button"])
            self.page.click(SELECTORS["comment_button"])
        except PlaywrightTimeout:
            return {
                "success": False,
                "message": "Could not find comment button",
                "url": url
            }
        
        # Type comment
        self.wait_for_selector(SELECTORS["comment_input"])
        self.page.fill(SELECTORS["comment_input"], text)
        
        # Submit comment
        self.page.click(SELECTORS["comment_submit"])
        
        # Wait for comment to appear
        try:
            self.page.wait_for_selector(
                f"{SELECTORS['comment_item']}:has-text('{text[:30]}')",
                timeout=5000
            )
            self.result = {
                "success": True,
                "message": "Comment added successfully",
                "text": text,
                "url": url,
                "timestamp": datetime.now().isoformat()
            }
        except PlaywrightTimeout:
            self.result = {
                "success": False,
                "message": "Comment may not have posted (timeout)",
                "text": text,
                "url": url
            }
        
        return self.result
    
    def get_analytics(self, count: int = 10) -> dict:
        """Get analytics for recent posts."""
        self.navigate(f"{URLS['profile']}/recent-activity/all/")
        
        posts = []
        post_elements = self.page.query_selector_all(SELECTORS["activity_post"])
        
        for post in post_elements[:count]:
            try:
                # Extract metrics (simplified)
                posts.append({
                    "url": "",
                    "engagement": "Data available via hover"
                })
            except Exception as e:
                if DEBUG:
                    print(f"Error parsing analytics: {e}")
        
        self.result = {
            "success": True,
            "posts": posts,
            "count": len(posts),
            "note": "Full analytics requires individual post scraping"
        }
        return self.result
    
    def get_profile_stats(self) -> dict:
        """Get profile-level statistics."""
        self.navigate(URLS["profile"])
        
        try:
            followers = self.page.text_content(SELECTORS["profile_followers"])
            self.result = {
                "success": True,
                "followers": followers,
                "profile_url": URLS["profile"],
                "timestamp": datetime.now().isoformat()
            }
        except Exception as e:
            self.result = {
                "success": False,
                "message": f"Could not fetch profile stats: {e}"
            }
        
        return self.result
    
    def scan_likes(self, count: int = 15) -> dict:
        """Monitor likes for new activity."""
        # Placeholder implementation
        # In production, this would track state and only return new likes
        self.result = {
            "success": True,
            "new_likes": [],
            "message": "Like monitoring placeholder (requires state tracking)",
            "timestamp": datetime.now().isoformat()
        }
        return self.result


def main():
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(description="LinkedIn Automation CLI")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    
    # Check session
    subparsers.add_parser("check-session", help="Check if session is valid")
    
    # Feed
    feed_parser = subparsers.add_parser("feed", help="Read LinkedIn feed")
    feed_parser.add_argument("--count", type=int, default=5, help="Number of posts")
    
    # Post
    post_parser = subparsers.add_parser("post", help="Create a post")
    post_parser.add_argument("--text", required=True, help="Post text")
    post_parser.add_argument("--image", help="Path to image")
    
    # Comment
    comment_parser = subparsers.add_parser("comment", help="Add comment")
    comment_parser.add_argument("--url", required=True, help="Post URL")
    comment_parser.add_argument("--text", required=True, help="Comment text")
    
    # Analytics
    analytics_parser = subparsers.add_parser("analytics", help="Get post analytics")
    analytics_parser.add_argument("--count", type=int, default=10, help="Number of posts")
    
    # Profile stats
    subparsers.add_parser("profile-stats", help="Get profile statistics")
    
    # Scan likes
    likes_parser = subparsers.add_parser("scan-likes", help="Monitor likes")
    likes_parser.add_argument("--count", type=int, default=15, help="Number of likes to check")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    # Run command
    with LinkedInAutomation() as linkedin:
        if args.command == "check-session":
            linkedin.check_session()
        elif args.command == "feed":
            linkedin.read_feed(args.count)
        elif args.command == "post":
            linkedin.create_post(args.text, args.image)
        elif args.command == "comment":
            linkedin.add_comment(args.url, args.text)
        elif args.command == "analytics":
            linkedin.get_analytics(args.count)
        elif args.command == "profile-stats":
            linkedin.get_profile_stats()
        elif args.command == "scan-likes":
            linkedin.scan_likes(args.count)


if __name__ == "__main__":
    main()
