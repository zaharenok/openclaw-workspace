# Telegram YouTube Monitor

## Overview

Мониторинг Telegram каналов для автоматического извлечения YouTube видео и отправки в n8n для обработки.

## Features

- ✅ Автоматическое извлечение YouTube ID из сообщений
- ✅ Поддержка всех форматов YouTube ссылок (youtube.com, youtu.be, shorts)
- ✅ Интеграция с n8n webhook
- ✅ Удаление дубликатов
- ✅ Подробные отчёты о статусе
- ✅ Кастомное количество сообщений для проверки

## Installation

```bash
# Install dependencies
pip3 install requests

# Make scripts executable (already done)
chmod +x ~/workspace/bin/telegram-youtube-monitor.{py,sh}
```

## Usage

### Basic Usage

```bash
# Проверить последние 10 сообщений
~/workspace/bin/telegram-youtube-monitor.sh @channelname

# Проверить последние 20 сообщений
~/workspace/bin/telegram-youtube-monitor.sh @channelname 20

# Проверить 50 сообщений из канала по ID
~/workspace/bin/telegram-youtube-monitor.sh -1234567890 50
```

### Advanced Usage

```bash
# Прямой запуск Python скрипта
python3 ~/workspace/bin/telegram-youtube-monitor.py @channelname 15

# Из cron (каждый час)
0 * * * * /root/.openclaw/workspace/bin/telegram-youtube-monitor.sh @channelname 20
```

## How It Works

```
1. Read Telegram messages (from OpenClaw cache or API)
   ↓
2. Parse message text for YouTube URLs
   ↓
3. Extract video IDs (all formats: watch, shorts, youtu.be)
   ↓
4. Remove duplicates
   ↓
5. Send to n8n webhook with metadata
   ↓
6. Return detailed report
```

## Output Format

```
🔍 Monitoring @channelname for YouTube videos...
📊 Processing last 20 messages

🎬 Found 3 YouTube video(s):

[1/3] Processing: dQw4w9WgXcQ
  ✅ Sent to n8n successfully

[2/3] Processing: abc123xyz456
  ✅ Sent to n8n successfully

[3/3] Processing: xyz789abc123
  ❌ Error: Connection timeout

📊 Summary:
  Total videos: 3
  Successful: 2
  Failed: 1
```

## n8n Webhook Integration

### Webhook URL
```
http://76.13.128.240:5678/webhook/9b601faa-5f51-477a-9d23-e95104ccd35d
```

### Payload Format
```json
{
  "video_id": "dQw4w9WgXcQ",
  "source": "@channelname",
  "timestamp": "2026-02-12T10:30:00Z",
  "webhook_token": "my-secret-token-2024"
}
```

## Integration with HEARTBEAT

Add to HEARTBEAT.md for periodic monitoring:

```markdown
# Telegram YouTube Monitor (ежедневно)
Когда видишь сообщение "[RUN_YOUTUBE_MONITOR] Запуск мониторинга YouTube", выполни:
```bash
/root/.openclaw/workspace/bin/telegram-youtube-monitor.sh @channelname 20
```
```

## Supported YouTube URL Formats

- `https://www.youtube.com/watch?v=VIDEO_ID`
- `https://youtube.com/watch?v=VIDEO_ID`
- `https://youtu.be/VIDEO_ID`
- `https://www.youtube.com/shorts/VIDEO_ID`
- `www.youtube.com/watch?v=VIDEO_ID` (without https)

## Error Handling

The script handles various error conditions:

- **No messages found**: Exits gracefully with tip
- **No YouTube videos**: Reports success with 0 videos
- **n8n webhook errors**: Reports each failed video individually
- **Network timeout**: 10-second timeout for webhook requests
- **Duplicate videos**: Removed automatically

## Troubleshooting

### No messages found
```
⚠️  No messages found for @channelname
💡 Tip: Make sure the channel is configured in OpenClaw
```

**Solution**: Check if the channel is accessible and configured in OpenClaw telegram settings.

### Webhook connection errors
```
❌ Error: Connection refused
```

**Solution**: Check if n8n server is running:
```bash
curl -X POST http://76.13.128.240:5678/webhook/test
```

### Permission denied
```
bash: ./telegram-youtube-monitor.sh: Permission denied
```

**Solution**: Make scripts executable:
```bash
chmod +x ~/workspace/bin/telegram-youtube-monitor.{py,sh}
```

## Related Tools

- **YouTube Transcription**: `~/workspace/bin/youtube-transcribe.sh`
- **YouTube Workflow**: `~/workspace/bin/youtube-workflow.sh`
- **n8n Webhook MCP**: `~/workspace/tools/mcp-n8n-webhook.sh`

## Future Enhancements

- [ ] Real-time monitoring via Telegram bot API
- [ ] Database logging of processed videos
- [ ] Automatic retry on webhook failures
- [ ] Multi-channel monitoring in single run
- [ ] Filtering by date range
- [ ] Video metadata extraction (title, duration, etc.)

## See Also

- `docs/youtube-transcription.md` - YouTube transcription workflow
- `knowledge/youtube/` - YouTube knowledge base
- `TOOLS.md` - MCP webhook configuration
