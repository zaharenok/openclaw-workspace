#!/usr/bin/env python3
"""
Content Calendar Webhook
Receives approve/edit/skip requests from a frontend UI for scheduled LinkedIn posts.
"""

import json
import os
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

# Configuration
CC_DATA_FILE = os.getenv("CC_DATA_FILE", "/tmp/cc-data.json")
CC_ACTIONS_FILE = os.getenv("CC_ACTIONS_FILE", "/tmp/cc-actions.json")
CC_WEBHOOK_PORT = int(os.getenv("CC_WEBHOOK_PORT", "8401"))


class ContentCalendarWebhook(BaseHTTPRequestHandler):
    """Handle webhook requests for content calendar actions."""
    
    def do_POST(self):
        """Handle POST requests."""
        # Parse request
        content_length = int(self.headers["Content-Length"])
        post_data = self.rfile.read(content_length)
        
        try:
            data = json.loads(post_data.decode("utf-8"))
            action = data.get("action")
            post_id = data.get("post_id")
            
            # Process action
            if action == "approve":
                result = self.approve_post(post_id, data)
            elif action == "edit":
                result = self.edit_post(post_id, data)
            elif action == "skip":
                result = self.skip_post(post_id, data)
            else:
                result = {"success": False, "message": f"Unknown action: {action}"}
            
            # Send response
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(result).encode("utf-8"))
        
        except Exception as e:
            self.send_response(400)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))
    
    def approve_post(self, post_id: str, data: dict) -> dict:
        """Approve a post for auto-publishing."""
        # Load data file
        with open(CC_DATA_FILE, "r") as f:
            cc_data = json.load(f)
        
        # Mark as approved
        if post_id in cc_data["posts"]:
            cc_data["posts"][post_id]["status"] = "approved"
            cc_data["posts"][post_id]["approved_at"] = datetime.now().isoformat()
        
        # Save data file
        with open(CC_DATA_FILE, "w") as f:
            json.dump(cc_data, f, indent=2)
        
        return {
            "success": True,
            "message": f"Post {post_id} approved",
            "post": cc_data["posts"][post_id]
        }
    
    def edit_post(self, post_id: str, data: dict) -> dict:
        """Edit a post (simple edits auto-applied, complex edits flagged)."""
        edit_text = data.get("edit_text", "")
        
        # Check if simple edit (old -> new format)
        if " -> " in edit_text:
            # Auto-apply simple edits
            old_text, new_text = edit_text.split(" -> ")
            
            with open(CC_DATA_FILE, "r") as f:
                cc_data = json.load(f)
            
            if post_id in cc_data["posts"]:
                cc_data["posts"][post_id]["text"] = new_text
                cc_data["posts"][post_id]["edited"] = True
            
            with open(CC_DATA_FILE, "w") as f:
                json.dump(cc_data, f, indent=2)
            
            return {
                "success": True,
                "message": "Edit applied automatically",
                "auto_applied": True,
                "post": cc_data["posts"][post_id]
            }
        else:
            # Flag complex edits for AI processing
            return {
                "success": True,
                "message": "Complex edit flagged for agent processing",
                "auto_applied": False,
                "requires_ai": True
            }
    
    def skip_post(self, post_id: str, data: dict) -> dict:
        """Skip a post (won't be published)."""
        with open(CC_DATA_FILE, "r") as f:
            cc_data = json.load(f)
        
        if post_id in cc_data["posts"]:
            cc_data["posts"][post_id]["status"] = "skipped"
        
        with open(CC_DATA_FILE, "w") as f:
            json.dump(cc_data, f, indent=2)
        
        return {
            "success": True,
            "message": f"Post {post_id} skipped",
            "post": cc_data["posts"][post_id]
        }
    
    def log_message(self, format, *args):
        """Suppress default logging."""
        pass


def main():
    """Start webhook server."""
    server = HTTPServer(("0.0.0.0", CC_WEBHOOK_PORT), ContentCalendarWebhook)
    print(f"Content calendar webhook server running on port {CC_WEBHOOK_PORT}")
    print(f"Data file: {CC_DATA_FILE}")
    print(f"Actions file: {CC_ACTIONS_FILE}")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down webhook server")
        server.shutdown()


if __name__ == "__main__":
    main()
