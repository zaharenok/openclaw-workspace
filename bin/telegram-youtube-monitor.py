#!/usr/bin/env python3
"""
Telegram YouTube Monitor
Читает сообщения из Telegram канала, извлекает YouTube ссылки и отправляет в n8n
"""

import re
import json
import sys
from typing import List, Dict, Optional
from datetime import datetime
import requests
from pathlib import Path

# YouTube URL patterns - YouTube video IDs are exactly 11 characters
YOUTUBE_PATTERNS = [
    r'(?:https?://)?(?:www\.)?youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})',
    r'(?:https?://)?(?:www\.)?youtube\.com/shorts/([a-zA-Z0-9_-]{11})',
    r'(?:https?://)?(?:www\.)?youtu\.be/([a-zA-Z0-9_-]{11})',
]

# n8n webhook для YouTube transcription
N8N_WEBHOOK_URL = "http://76.13.128.240:5678/webhook/9b601faa-5f51-477a-9d23-e95104ccd35d"
N8N_WEBHOOK_TOKEN = "my-secret-token-2024"

# OpenClaw telegram cache
TELEGRAM_CACHE_DIR = Path.home() / ".openclaw" / "cache" / "telegram"


def extract_youtube_ids(text: str) -> List[str]:
    """Извлекает YouTube ID из текста"""
    ids = []
    for pattern in YOUTUBE_PATTERNS:
        matches = re.findall(pattern, text)
        ids.extend(matches)
    return list(set(ids))  # Убираем дубликаты


def get_telegram_messages(channel_id: str, limit: int = 10) -> List[Dict]:
    """
    Читает сообщения из Telegram через OpenClaw message tool
    Для этого нужно использовать sessions_history или читать cache
    """
    messages = []
    
    # Пытаемся прочитать из OpenClaw cache
    try:
        cache_file = TELEGRAM_CACHE_DIR / f"{channel_id}_messages.json"
        if cache_file.exists():
            with open(cache_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                messages = data.get('messages', [])
    except Exception as e:
        print(f"Error reading cache: {e}", file=sys.stderr)
    
    return messages


def send_to_n8n(video_id: str, source_channel: str = "telegram") -> Dict:
    """Отправляет видео ID в n8n webhook"""
    
    payload = {
        "video_id": video_id,
        "source": source_channel,
        "timestamp": datetime.utcnow().isoformat(),
        "webhook_token": N8N_WEBHOOK_TOKEN
    }
    
    try:
        response = requests.post(
            N8N_WEBHOOK_URL,
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        response.raise_for_status()
        return {
            "success": True,
            "video_id": video_id,
            "status_code": response.status_code,
            "response": response.json() if response.content else {}
        }
    except Exception as e:
        return {
            "success": False,
            "video_id": video_id,
            "error": str(e)
        }


def main():
    """Main entry point"""
    if len(sys.argv) < 2 or sys.argv[1] in ['-h', '--help']:
        print("Usage: telegram-youtube-monitor.py <channel_id> [limit]", file=sys.stderr)
        print("", file=sys.stderr)
        print("Arguments:", file=sys.stderr)
        print("  channel_id  Telegram channel ID (@channelname or -1001234567890)", file=sys.stderr)
        print("  limit       Number of messages to check (default: 10)", file=sys.stderr)
        print("", file=sys.stderr)
        print("Examples:", file=sys.stderr)
        print("  telegram-youtube-monitor.py @telegram_channel", file=sys.stderr)
        print("  telegram-youtube-monitor.py @telegram_channel 20", file=sys.stderr)
        print("  telegram-youtube-monitor.py -1234567890 50", file=sys.stderr)
        sys.exit(0 if len(sys.argv) > 1 else 1)
    
    channel_id = sys.argv[1]
    limit = int(sys.argv[2]) if len(sys.argv) > 2 else 10
    
    print(f"🔍 Monitoring {channel_id} for YouTube videos...")
    print(f"📊 Processing last {limit} messages\n")
    
    # Получаем сообщения
    messages = get_telegram_messages(channel_id, limit)
    
    if not messages:
        print(f"⚠️  No messages found for {channel_id}")
        print("💡 Tip: Make sure the channel is configured in OpenClaw")
        sys.exit(0)
    
    # Извлекаем YouTube ID
    video_ids = []
    for msg in messages:
        text = msg.get('text', '')
        if text:
            ids = extract_youtube_ids(text)
            video_ids.extend(ids)
    
    video_ids = list(set(video_ids))  # Убираем дубликаты
    
    if not video_ids:
        print(f"✅ No YouTube videos found in last {limit} messages")
        sys.exit(0)
    
    print(f"🎬 Found {len(video_ids)} YouTube video(s):\n")
    
    # Отправляем в n8n
    results = []
    for i, video_id in enumerate(video_ids, 1):
        print(f"[{i}/{len(video_ids)}] Processing: {video_id}")
        
        result = send_to_n8n(video_id, channel_id)
        results.append(result)
        
        if result['success']:
            print(f"  ✅ Sent to n8n successfully")
        else:
            print(f"  ❌ Error: {result.get('error', 'Unknown')}")
    
    # Summary
    print(f"\n📊 Summary:")
    print(f"  Total videos: {len(video_ids)}")
    print(f"  Successful: {sum(1 for r in results if r['success'])}")
    print(f"  Failed: {sum(1 for r in results if not r['success'])}")


if __name__ == "__main__":
    main()
