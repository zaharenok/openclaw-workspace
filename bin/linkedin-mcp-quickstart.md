# LinkedIn MCP - Quick Start

## 🚀 Quick Start

### Test Installation

```bash
# Проверить сессию LinkedIn
~/workspace/bin/linkedin-mcp.sh check-session

# Читать feed (5 постов)
~/workspace/bin/linkedin-mcp.sh feed

# Аналитика (10 постов)
~/workspace/bin/linkedin-mcp.sh analytics 10
```

## 📋 Commands Reference

```bash
# Feed (последние N постов)
~/workspace/bin/linkedin-mcp.sh feed [count]

# Аналитика вовлеченности
~/workspace/bin/linkedin-mcp.sh analytics [count]

# Статистика профиля
~/workspace/bin/linkedin-mcp.sh profile-stats

# Мониторинг новых лайков
~/workspace/bin/linkedin-mcp.sh scan-likes [count]

# Активность профиля
~/workspace/bin/linkedin-mcp.sh activity "https://linkedin.com/in/username" [count]

# Проверить сессию
~/workspace/bin/linkedin-mcp.sh check-session
```

## 🔗 Via mcporter

```bash
# Добавить LinkedIn MCP
mcporter config add linkedin \
  --stdio "python3 /root/.openclaw/workspace/skills/linkedin-automation/linkedin_mcp.py"

# Использовать инструменты
mcporter call linkedin.read_feed count:10
mcporter call linkedin.analytics count:20
mcporter call linkedin.check_session
```

## 🔄 Automation

### HEARTBEAT Integration

Добавить в `HEARTBEAT.md`:

```markdown
# LinkedIn Analytics (ежедневно в 9:00 Vienna)
Когда видишь сообщение "[RUN_LINKEDIN_ANALYTICS] Запуск аналитики LinkedIn", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20
```

# LinkedIn Likes Monitor (ежедневно)
Когда видишь сообщение "[RUN_LINKEDIN_LIKES] Мониторинг новых лайков", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh scan-likes 25
```
```

### Cron Jobs

```bash
crontab -e

# Ежедневная аналитика (9:00 Vienna = 8:00 UTC)
0 8 * * * /root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20

# Проверка feed каждые 4 часа
0 */4 * * * /root/.openclaw/workspace/bin/linkedin-mcp.sh feed 10

# Мониторинг лайков (18:00 Vienna = 17:00 UTC)
0 17 * * * /root/.openclaw/workspace/bin/linkedin-mcp.sh scan-likes 25
```

## 📊 Output Examples

### Feed Reading

```json
{
  "posts": [
    {
      "url": "https://linkedin.com/feed/update/urn:li:activity:1234567890",
      "author": "John Doe",
      "text": "Just published an article about AI automation...",
      "likes": 42,
      "comments": 7,
      "reposts": 3,
      "timestamp": "2026-02-12T10:30:00Z"
    }
  ]
}
```

### Analytics

```json
{
  "posts": [
    {
      "url": "...",
      "likes": 42,
      "comments": 7,
      "reposts": 3,
      "engagement_rate": "3.4%"
    }
  ],
  "averages": {
    "likes": 35.2,
    "comments": 5.8,
    "engagement_rate": "2.9%"
  }
}
```

### Scan Likes (новые)

```json
{
  "new_likes": [
    {
      "post_url": "...",
      "post_author": "Jane Smith",
      "liked_by": "Mike Johnson",
      "timestamp": "2026-02-12T09:15:00Z"
    }
  ],
  "new_count": 1,
  "total_checked": 15
}
```

## 🔧 Troubleshooting

### "Session expired"
```bash
cd /root/.openclaw/workspace/skills/linkedin-automation
./setup-linkedin-session.sh
```

### Debug mode
```bash
LINKEDIN_DEBUG=1 ~/workspace/bin/linkedin-mcp.sh feed 5
```

## 📚 Full Documentation

- **Complete guide:** `~/workspace/docs/linkedin-mcp-server.md`
- **LinkedIn Automation Skill:** `~/workspace/skills/linkedin-automation/SKILL.md`
- **Content Strategy:** `~/workspace/skills/linkedin-automation/references/content-strategy.md`

## ⚡ Rate Limits

| Action | Daily Max | Safe Limit |
|--------|-----------|-------------|
| Feed reads | 100 | 50 |
| Analytics | 50 | 20 |
| Profile stats | 20 | 10 |
| Likes scan | 100 | 50 |

**Best practice:** Feed - каждые 4-6 часов, Analytics - 1-2 раза в день

---

**Status:** ✅ Production Ready
**Version:** 1.0.0
**Created:** 2026-02-12
