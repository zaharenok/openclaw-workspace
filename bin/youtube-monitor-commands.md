# Telegram YouTube Monitor - Quick Reference

## Basic Commands

```bash
# Monitor last 10 messages from a channel
~/workspace/bin/telegram-youtube-monitor.sh @channelname

# Monitor last 20 messages
~/workspace/bin/telegram-youtube-monitor.sh @channelname 20

# Monitor last 50 messages from channel by ID
~/workspace/bin/telegram-youtube-monitor.sh -1234567890 50

# Show help
~/workspace/bin/telegram-youtube-monitor.sh --help
```

## Integration Examples

### 1. Manual Run (Ad-hoc)
```bash
# Check for new videos from your favorite channel
~/workspace/bin/telegram-youtube-monitor.sh @TechChannel 30

# Check multiple channels
~/workspace/bin/telegram-youtube-monitor.sh @ChannelA 20
~/workspace/bin/telegram-youtube-monitor.sh @ChannelB 20
~/workspace/bin/telegram-youtube-monitor.sh @ChannelC 20
```

### 2. Cron Jobs (Automated)
```bash
# Edit crontab
crontab -e

# Add these lines:
# Check every hour
0 * * * * /root/.openclaw/workspace/bin/telegram-youtube-monitor.sh @channelname 20

# Check every 6 hours
0 */6 * * * /root/.openclaw/workspace/bin/telegram-youtube-monitor.sh @channelname 50

# Check at specific time (9 AM Vienna time = 8 AM UTC)
0 8 * * * /root/.openclaw/workspace/bin/telegram-youtube-monitor.sh @channelname 30
```

### 3. HEARTBEAT Integration
Add to `HEARTBEAT.md`:
```markdown
# Telegram YouTube Monitor (ежедневно в 9:00 Vienna)
Когда видишь сообщение "[RUN_YOUTUBE_MONITOR] Запуск мониторинга YouTube", выполни:
```bash
/root/.openclaw/workspace/bin/telegram-youtube-monitor.sh @channelname 20
```
```

### 4. OpenClaw Sessions
```bash
# Send to another session for processing
sessions_send --label="youtube-processor" \
  "Check @TechChannel for new YouTube videos and transcribe them"

# The other session can run:
~/workspace/bin/telegram-youtube-monitor.sh @TechChannel 30
```

## Use Cases

### Content Curator
Monitor YouTube creators who post in Telegram channels:
```bash
~/workspace/bin/telegram-youtube-monitor.sh @IndieHackers 50
```

### News Aggregator
Track news channels that share YouTube videos:
```bash
~/workspace/bin/telegram-youtube-monitor.sh @TechNewsDaily 100
```

### Tutorial Collector
Monitor educational channels:
```bash
~/workspace/bin/telegram-youtube-monitor.sh @ProgrammingTutorials 30
```

## n8n Workflow

### Expected Webhook Payload
```json
{
  "video_id": "dQw4w9WgXcQ",
  "source": "@channelname",
  "timestamp": "2026-02-12T10:30:00Z",
  "webhook_token": "my-secret-token-2024"
}
```

### n8n Workflow Steps
1. **Webhook** - Receives video ID
2. **Filter** - Validate token and check duplicates
3. **HTTP Request** - Get video metadata from YouTube API
4. **HTTP Request** - Download transcript/captions
5. **AI Processing** - Summarize, extract key points
6. **Database** - Store processed video info
7. **Notification** - Send summary back to Telegram

## Troubleshooting

### "No messages found"
- Check if channel is accessible
- Verify channel ID is correct
- Check OpenClaw telegram configuration

### "Webhook connection errors"
- Verify n8n server is running
- Check webhook URL is correct
- Test webhook manually: `curl -X POST http://76.13.128.240:5678/webhook/test`

### "Permission denied"
- Make scripts executable: `chmod +x ~/workspace/bin/telegram-youtube-monitor.{py,sh}`

## Related Tools

- `youtube-transcribe.sh` - Direct YouTube transcription
- `youtube-workflow.sh` - Full n8n workflow trigger
- `mcp-n8n-webhook.sh` - Generic n8n webhook caller

## Status

✅ Core functionality implemented
✅ YouTube ID extraction tested
✅ n8n webhook integration ready
✅ Error handling implemented
⏳ Real-time monitoring (via Telegram Bot API)
⏳ Database logging
⏳ Auto-retry on failures

---

**Last updated:** 2026-02-12
**Status:** Production Ready ✅
