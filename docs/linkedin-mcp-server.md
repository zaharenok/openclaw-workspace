# LinkedIn MCP Server - Documentation

## Overview

LinkedIn MCP Server позволяет мониторить посты, комментарии и аналитику LinkedIn через MCP протокол. Интегрируется с OpenClaw и mcporter.

## Features

- ✅ **Read Feed** - Чтение LinkedIn ленты постов
- ✅ **Analytics** - Аналитика вовлеченности (лайки, комментарии, репосты)
- ✅ **Profile Stats** - Статистика профиля (подписчики, просмотры)
- ✅ **Scan Likes** - Мониторинг новых лайков
- ✅ **Activity** - Сбор активности с любого профиля
- ✅ **Session Check** - Проверка валидности сессии

## Installation

Уже установлено в `/root/.openclaw/workspace/skills/linkedin-automation/`

### Зависимости

```bash
# Python зависимости
pip install playwright
playwright install chromium

# LinkedIn сессия
cd /root/.openclaw/workspace/skills/linkedin-automation
./setup-linkedin-session.sh
```

## Usage

### 1. CLI Wrapper (рекомендуется)

```bash
# Читать последние 10 постов
~/workspace/bin/linkedin-mcp.sh feed 10

# Проверить сессию
~/workspace/bin/linkedin-mcp.sh check-session

# Аналитика последних 20 постов
~/workspace/bin/linkedin-mcp.sh analytics 20

# Статистика профиля
~/workspace/bin/linkedin-mcp.sh profile-stats

# Мониторинг лайков (последние 25)
~/workspace/bin/linkedin-mcp.sh scan-likes 25

# Активность профиля
~/workspace/bin/linkedin-mcp.sh activity "https://linkedin.com/in/username" 10
```

### 2. Через mcporter

```bash
# Добавить MCP сервер
mcporter config add linkedin \
  --stdio "python3 /root/.openclaw/workspace/skills/linkedin-automation/linkedin_mcp.py"

# Использовать инструменты
mcporter call linkedin.read_feed count:10
mcporter call linkedin.check_session
mcporter call linkedin.analytics count:20
mcporter call linkedin.profile_stats
mcporter call linkedin.scan_likes count:25
mcporter call linkedin.activity profileUrl:"https://linkedin.com/in/username" count:10
```

### 3. Прямой Python импорт

```python
import sys
sys.path.insert(0, '/root/.openclaw/workspace/skills/linkedin-automation')

from linkedin_mcp import call_linkedin

# Читать feed
result = call_linkedin("feed", ["--count", "10"])
print(result)

# Аналитика
result = call_linkedin("analytics", ["--count", "20"])
print(result)
```

## MCP Tools

### read_feed

Читает посты из LinkedIn ленты.

**Parameters:**
- `count` (number, optional): Количество постов (default: 5)

**Returns:**
```json
{
  "posts": [
    {
      "url": "https://linkedin.com/feed/update/...",
      "author": "Author Name",
      "text": "Post content...",
      "likes": 42,
      "comments": 7,
      "reposts": 3,
      "timestamp": "2026-02-12T10:30:00Z"
    }
  ]
}
```

**Example:**
```bash
mcporter call linkedin.read_feed count:10
```

---

### check_session

Проверяет валидность LinkedIn сессии.

**Parameters:** None

**Returns:**
```json
{
  "valid": true,
  "profile": "https://linkedin.com/in/username",
  "session_age": "2 days"
}
```

**Example:**
```bash
mcporter call linkedin.check_session
```

---

### analytics

Получает аналитику вовлеченности для последних постов.

**Parameters:**
- `count` (number, optional): Количество постов (default: 10)

**Returns:**
```json
{
  "posts": [
    {
      "url": "https://linkedin.com/feed/update/...",
      "likes": 42,
      "comments": 7,
      "reposts": 3,
      "impressions": 1234,
      "engagement_rate": "3.4%"
    }
  ],
  "averages": {
    "likes": 35.2,
    "comments": 5.8,
    "reposts": 2.1,
    "engagement_rate": "2.9%"
  }
}
```

**Example:**
```bash
mcporter call linkedin.analytics count:20
```

---

### profile_stats

Получает статистику профиля.

**Parameters:** None

**Returns:**
```json
{
  "followers": 1234,
  "connections": 856,
  "profile_views": 234,
  "search_appearances": 45,
  "post_impressions": 5678
}
```

**Example:**
```bash
mcporter call linkedin.profile_stats
```

---

### scan_likes

Мониторинг новых лайков (с последней проверки).

**Parameters:**
- `count` (number, optional): Количество элементов для проверки (default: 15)

**Returns:**
```json
{
  "new_likes": [
    {
      "post_url": "https://linkedin.com/feed/update/...",
      "author": "Author Name",
      "liked_by": "Liker Name",
      "timestamp": "2026-02-12T10:30:00Z"
    }
  ],
  "total_checked": 15,
  "new_count": 3
}
```

**Example:**
```bash
mcporter call linkedin.scan_likes count:25
```

---

### activity

Сбор активности с любого профиля.

**Parameters:**
- `profileUrl` (string, required): URL профиля LinkedIn
- `count` (number, optional): Количество активностей (default: 5)

**Returns:**
```json
{
  "activities": [
    {
      "type": "post",
      "url": "https://linkedin.com/feed/update/...",
      "text": "Post content...",
      "timestamp": "2026-02-12T10:30:00Z",
      "likes": 42,
      "comments": 7
    }
  ]
}
```

**Example:**
```bash
mcporter call linkedin.activity profileUrl:"https://linkedin.com/in/username" count:10
```

## Integration with OpenClaw

### HEARTBEAT (ежедневно)

Добавить в `HEARTBEAT.md`:

```markdown
# LinkedIn Analytics (ежедневно в 9:00 Vienna)
Когда видишь сообщение "[RUN_LINKEDIN_ANALYTICS] Запуск аналитики LinkedIn", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20
```

# LinkedIn Feed Monitor (каждые 4 часа)
Когда видишь сообщение "[RUN_LINKEDIN_FEED] Проверка новых постов", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh feed 10
```

# LinkedIn Likes Monitor (ежедневно)
Когда видишь сообщение "[RUN_LINKEDIN_LIKES] Мониторинг новых лайков", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh scan-likes 25
```
```

### Cron Jobs

```bash
# Редактировать crontab
crontab -e

# Добавить задачи:
# Ежедневная аналитика в 9:00 Vienna (8:00 UTC)
0 8 * * * /root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20

# Проверка feed каждые 4 часа
0 */4 * * * /root/.openclaw/workspace/bin/linkedin-mcp.sh feed 10

# Мониторинг лайков ежедневно в 18:00 Vienna (17:00 UTC)
0 17 * * * /root/.openclaw/workspace/bin/linkedin-mcp.sh scan-likes 25
```

### Sessions (multi-agent)

```bash
# Создать под-агент для LinkedIn мониторинга
sessions_spawn \
  --label="linkedin-monitor" \
  --task="Monitor LinkedIn feed, analytics, and likes. Report significant changes." \
  --timeout=3600

# Отправить задачу в сессию
sessions_send \
  --sessionKey="linkedin-monitor" \
  --message="Check LinkedIn analytics for last 20 posts"
```

## Output Examples

### Read Feed

```json
{
  "posts": [
    {
      "url": "https://linkedin.com/feed/update/urn:li:activity:1234567890",
      "author": "John Doe",
      "author_url": "https://linkedin.com/in/johndoe",
      "text": "Just published an article about AI automation...",
      "likes": 42,
      "comments": 7,
      "reposts": 3,
      "timestamp": "2026-02-12T10:30:00Z",
      "age_hours": 2
    }
  ]
}
```

### Analytics

```json
{
  "posts": [
    {
      "url": "https://linkedin.com/feed/update/urn:li:activity:1234567890",
      "likes": 42,
      "comments": 7,
      "reposts": 3,
      "impressions": 1234,
      "engagement_rate": "3.4%"
    }
  ],
  "averages": {
    "likes": 35.2,
    "comments": 5.8,
    "reposts": 2.1,
    "engagement_rate": "2.9%"
  },
  "top_performing": [
    {
      "url": "...",
      "metric": "likes",
      "value": 42
    }
  ]
}
```

### Profile Stats

```json
{
  "followers": 1234,
  "followers_change": "+12",
  "followers_change_percent": "+1.0%",
  "connections": 856,
  "profile_views": 234,
  "search_appearances": 45,
  "post_impressions": 5678
}
```

### Scan Likes (новые лайки)

```json
{
  "new_likes": [
    {
      "post_url": "https://linkedin.com/feed/update/...",
      "post_author": "Jane Smith",
      "post_text": "Great insights on...",
      "liked_by": "Mike Johnson",
      "liked_by_url": "https://linkedin.com/in/mikejohnson",
      "timestamp": "2026-02-12T09:15:00Z"
    }
  ],
  "total_checked": 15,
  "new_count": 1
}
```

## Troubleshooting

### "Session expired"

**Problem:** LinkedIn сессия истекла

**Solution:**
```bash
cd /root/.openclaw/workspace/skills/linkedin-automation
./setup-linkedin-session.sh
```

### "No posts found"

**Problem:** Нет постов в ленте

**Solution:**
- Проверьте что сессия активна: `~/workspace/bin/linkedin-mcp.sh check-session`
- Увеличьте `count` параметр
- Убедитесь что вы залогинены в LinkedIn

### "Browser not found"

**Problem:** Playwright браузер не установлен

**Solution:**
```bash
pip install playwright
playwright install chromium
```

### "Permission denied"

**Problem:** Нет прав на выполнение скрипта

**Solution:**
```bash
chmod +x ~/workspace/bin/linkedin-mcp.sh
chmod +x /root/.openclaw/workspace/skills/linkedin-automation/linkedin_mcp.py
```

### Debug Mode

Для отладки включите `LINKEDIN_DEBUG=1`:

```bash
LINKEDIN_DEBUG=1 ~/workspace/bin/linkedin-mcp.sh feed 5
```

## Rate Limits

LinkedIn имеет строгие rate limits:

| Action | Daily Max | Safe Limit |
|--------|-----------|-------------|
| Feed reads | 100 | 50 |
| Analytics | 50 | 20 |
| Profile stats | 20 | 10 |
| Activity scrape | 30 | 10 |
| Likes scan | 100 | 50 |

**Recommendations:**
- Не читайте feed чаще чем каждые 2 часа
- Analytics запускайте 1-2 раза в день
- Используйте кеширование результатов

## Best Practices

### 1. Monitore By Frequency

- **Feed:** Каждые 4-6 часов
- **Analytics:** Ежедневно или раз в 2 дня
- **Profile Stats:** Раз в неделю
- **Likes Scan:** Ежедневно

### 2. Batch Requests

Группируйте запросы к LinkedIn API:
```bash
# Плохо (отдельные вызовы)
~/workspace/bin/linkedin-mcp.sh feed 5
~/workspace/bin/linkedin-mcp.sh analytics 10
~/workspace/bin/linkedin-mcp.sh profile-stats

# Хорошо (один вызов с большим count)
~/workspace/bin/linkedin-mcp.sh feed 20  # Включает analytics
```

### 3. Error Handling

Всегда проверяйте `success` поле в ответе:
```python
result = call_linkedin("feed", ["--count", "10"])
if not result.get("success"):
    print(f"Error: {result.get('error')}")
    # Обработка ошибки
```

### 4. Caching

Кешируйте результаты чтобы избежать лишних вызов:
```python
import time
from pathlib import Path

CACHE_FILE = Path("/tmp/linkedin_cache.json")

def get_cached_feed(max_age=3600):
    if CACHE_FILE.exists():
        age = time.time() - CACHE_FILE.stat().st_mtime
        if age < max_age:
            return json.loads(CACHE_FILE.read_text())
    
    # Кеш устарел - обновить
    result = call_linkedin("feed", ["--count", "20"])
    CACHE_FILE.write_text(json.dumps(result))
    return result
```

## Advanced Usage

### Custom Analytics

Создайте кастомную аналитику:

```python
from linkedin_mcp import call_linkedin
import json

def custom_analytics():
    # Получить feed
    feed_result = call_linkedin("feed", ["--count", "50"])
    
    if not feed_result.get("success"):
        return {"error": feed_result.get("error")}
    
    posts = feed_result["data"].get("posts", [])
    
    # Кастомная логика
    top_posts = sorted(posts, key=lambda x: x["likes"], reverse=True)[:5]
    
    avg_engagement = sum(p["likes"] for p in posts) / len(posts)
    
    return {
        "top_posts": top_posts,
        "avg_engagement": avg_engagement,
        "total_posts": len(posts)
    }

# Использование
result = custom_analytics()
print(json.dumps(result, indent=2))
```

### Multi-Profile Monitoring

Мониторинг нескольких профилей:

```python
profiles = [
    "https://linkedin.com/in/user1",
    "https://linkedin.com/in/user2",
    "https://linkedin.com/in/user3"
]

for profile_url in profiles:
    result = call_linkedin("activity", [
        "--profile-url", profile_url,
        "--count", "10"
    ])
    
    if result.get("success"):
        print(f"{profile_url}: {len(result['data'].get('activities', []))} activities")
```

## Related Tools

- **LinkedIn Automation Skill** - `/root/.openclaw/workspace/skills/linkedin-automation/`
- **LinkedIn Session Setup** - `setup-linkedin-session.sh`
- **Content Calendar** - `references/content-calendar.md`
- **Engagement Strategy** - `references/engagement.md`

## Future Enhancements

- [ ] Real-time streaming (WebSocket)
- [ ] Comment monitoring
- [ ] Post scheduling
- [ ] Auto-engagement (likes, comments)
- [ ] Competitor tracking
- [ ] Sentiment analysis
- [ ] Trending topics detection

## Status

✅ **Production Ready** - Core functionality implemented
⏳ **Beta** - Advanced features in development
🚧 **Experimental** - New features testing

---

**Last updated:** 2026-02-12
**Version:** 1.0.0
**Documentation:** Full guide for LinkedIn MCP Server
