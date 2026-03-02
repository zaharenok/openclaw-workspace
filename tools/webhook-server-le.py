#!/usr/bin/env python3
"""
OpenClaw Webhook Server (HTTPS with Let's Encrypt)
Receives webhooks and forwards them to OpenClaw session
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os
import ssl
from datetime import datetime

# Configuration
WEBHOOK_PORT = int(os.getenv("WEBHOOK_PORT", "8443"))
WEBHOOK_TOKEN = os.getenv("WEBHOOK_TOKEN", "openclaw-webhook-2026")
OPENCLAW_SESSION = os.getenv("OPENCLAW_SESSION", "main")
WEBHOOK_LOG = "/tmp/openclaw-webhooks.jsonl"

class WebhookHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        """Suppress default logging"""
        pass

    def send_response(self, code, message=None):
        """Send response with headers"""
        super().send_response(code, message)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()

    def do_GET(self):
        """Handle GET requests"""
        if self.path == '/':
            self.send_response(200)
            self.wfile.write(json.dumps({
                "status": "running",
                "service": "OpenClaw Webhook Server (HTTPS + Let's Encrypt)",
                "session": OPENCLAW_SESSION,
                "timestamp": datetime.utcnow().isoformat()
            }).encode())

        elif self.path == '/health':
            self.send_response(200)
            self.wfile.write(json.dumps({
                "status": "healthy",
                "timestamp": datetime.utcnow().isoformat()
            }).encode())

    def do_POST(self):
        """Handle POST requests (webhooks)"""
        if self.path == '/webhook':
            try:
                # Get content length and read body
                content_length = int(self.headers.get('Content-Length', 0))
                post_data = self.rfile.read(content_length)

                # Parse JSON
                data = json.loads(post_data.decode('utf-8'))

                # Verify token
                auth_token = self.headers.get('X-Webhook-Token', '')
                if WEBHOOK_TOKEN and auth_token != WEBHOOK_TOKEN:
                    print(f"⚠️  Invalid auth token from {self.client_address[0]}")
                    self.send_response(401)
                    self.wfile.write(json.dumps({"error": "Invalid token"}).encode())
                    return

                # Extract data
                source = data.get("source", "unknown")
                message = data.get("message", str(data))

                # Log webhook
                log_entry = {
                    "timestamp": datetime.utcnow().isoformat(),
                    "source": source,
                    "data": data
                }
                with open(WEBHOOK_LOG, "a") as f:
                    f.write(json.dumps(log_entry) + "\n")

                print(f"[{datetime.utcnow().isoformat()}] 📩 Webhook from {source}")
                print(f"   Message: {message[:100]}{'...' if len(message) > 100 else ''}")

                # Send success response
                self.send_response(200)
                self.wfile.write(json.dumps({
                    "status": "success",
                    "received_at": datetime.utcnow().isoformat(),
                    "source": source
                }).encode())

            except Exception as e:
                print(f"❌ Error processing webhook: {e}")
                self.send_response(400)
                self.wfile.write(json.dumps({"error": str(e)}).encode())
        else:
            self.send_response(404)
            self.wfile.write(json.dumps({"error": "Not found"}).encode())

def run_server():
    """Start HTTPS webhook server"""
    server_address = ('0.0.0.0', WEBHOOK_PORT)
    httpd = HTTPServer(server_address, WebhookHandler)

    # SSL context with Let's Encrypt certificate
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain('/etc/letsencrypt/live/srv1303227.hstgr.cloud/fullchain.pem',
                              '/etc/letsencrypt/live/srv1303227.hstgr.cloud/privkey.pem')

    httpd.socket = context.wrap_socket(httpd.socket)

    print(f"🚀 OpenClaw Webhook Server (HTTPS + Let's Encrypt) starting on port {WEBHOOK_PORT}")
    print(f"📡 Webhook endpoint: https://0.0.0.0:{WEBHOOK_PORT}/webhook")
    print(f"💬 Session: {OPENCLAW_SESSION}")
    print(f"🔒 Token required: {bool(WEBHOOK_TOKEN)}")
    print(f"📝 Log file: {WEBHOOK_LOG}")
    print(f"🔐 SSL: Let's Encrypt valid certificate")
    print(f"✅ Server ready!")

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n⏹️  Server stopped")
        httpd.server_close()

if __name__ == "__main__":
    run_server()
