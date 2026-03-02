#!/usr/bin/env python3
"""
Send webhook to OpenClaw server (HTTPS version)
"""

import sys
import json
import requests
from datetime import datetime

WEBHOOK_URL = "https://srv1303227.hstgr.cloud:8443/webhook"
WEBHOOK_TOKEN = "openclaw-webhook-2026"

def send_webhook(message: str, source: str = "manual"):
    """Send webhook to OpenClaw"""
    payload = {
        "message": message,
        "source": source,
        "timestamp": datetime.utcnow().isoformat()
    }

    headers = {
        "Content-Type": "application/json",
        "X-Webhook-Token": WEBHOOK_TOKEN
    }

    try:
        response = requests.post(WEBHOOK_URL, json=payload, headers=headers, timeout=5, verify=False)
        response.raise_for_status()
        print(f"✅ Webhook sent successfully")
        print(f"   Response: {response.json()}")
        return True
    except Exception as e:
        print(f"❌ Error sending webhook: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: send-webhook.py 'message' [source]")
        print("Example: send-webhook.py 'Check this out' 'test'")
        sys.exit(1)

    message = sys.argv[1]
    source = sys.argv[2] if len(sys.argv) > 2 else "manual"

    send_webhook(message, source)
