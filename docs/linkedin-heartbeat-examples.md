# LinkedIn MCP - HEARTBEAT Integration Examples

## Basic Monitoring (ежедневно)

```markdown
# LinkedIn Analytics (ежедневно в 9:00 Vienna)
Когда видишь сообщение "[RUN_LINKEDIN_ANALYTICS] Запуск аналитики LinkedIn", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20
```
```

## Feed Monitoring (каждые 4 часа)

```markdown
# LinkedIn Feed Monitor (каждые 4 часа)
Когда видишь сообщение "[RUN_LINKEDIN_FEED] Проверка новых постов LinkedIn", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh feed 10
```
```

## Likes Monitoring (ежедневно)

```markdown
# LinkedIn Likes Monitor (ежедневно в 18:00 Vienna)
Когда видишь сообщение "[RUN_LINKEDIN_LIKES] Мониторинг новых лайков LinkedIn", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh scan-likes 25
```
```

## Profile Stats (еженедельно)

```markdown
# LinkedIn Profile Stats (еженедельно в понедельник 9:00)
Когда видишь сообщение "[RUN_LINKEDIN_PROFILE] Статистика профиля LinkedIn", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh profile-stats
```
```

## Competitor Monitoring (ежедневно)

```markdown
# Competitor Activity Monitor (ежедневно в 10:00)
Когда видишь сообщение "[RUN_COMPETITOR_MONITOR] Мониторинг активности конкурентов", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh activity "https://linkedin.com/in/competitor1" 5
/root/.openclaw/workspace/bin/linkedin-mcp.sh activity "https://linkedin.com/in/competitor2" 5
```
```

## Full Daily Check (комплексный)

```markdown
# LinkedIn Daily Check (ежедневно в 9:00 Vienna)
Когда видишь сообщение "[RUN_LINKEDIN_DAILY] Полная проверка LinkedIn", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh check-session
/root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20
/root/.openclaw/workspace/bin/linkedin-mcp.sh scan-likes 25
```
```

## Smart Reporting (с анализом)

```markdown
# LinkedIn Smart Report (ежедневно в 9:00 Vienna)
Когда видишь сообщение "[RUN_LINKEDIN_SMART] Умный отчёт LinkedIn", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20 | jq '.averages'
/root/.openclaw/workspace/bin/linkedin-mcp.sh scan-likes 25 | jq '.new_count'
```
```

## Multi-Channel Strategy (несколько каналов)

```markdown
# LinkedIn Multi-Channel (ежедневно)
Когда видишь сообщение "[RUN_LINKEDIN_MULTI] Проверка всех LinkedIn каналов", выполни:
```bash
# Основной профиль
/root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20

# Конкурент 1
/root/.openclaw/workspace/bin/linkedin-mcp.sh activity "https://linkedin.com/in/competitor1" 10

# Конкурент 2
/root/.openclaw/workspace/bin/linkedin-mcp.sh activity "https://linkedin.com/in/competitor2" 10
```
```

## Integration Examples

### 1. Basic Daily Check

**Add to HEARTBEAT.md:**
```markdown
# LinkedIn Analytics (ежедневно в 9:00 Vienna)
Когда видишь сообщение "[RUN_LINKEDIN_ANALYTICS] Запуск аналитики LinkedIn", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20
```
```

**What it does:**
- Checks engagement for last 20 posts
- Calculates average likes, comments, reposts
- Shows engagement rate
- Identifies top-performing posts

### 2. Feed + Likes Combo

**Add to HEARTBEAT.md:**
```markdown
# LinkedIn Feed & Likes (каждые 6 часов)
Когда видишь сообщение "[RUN_LINKEDIN_FEED_LIKES] Проверка feed и лайков", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh feed 10
/root/.openclaw/workspace/bin/linkedin-mcp.sh scan-likes 25
```
```

**What it does:**
- Reads last 10 posts from feed
- Scans for new likes
- Returns both in one check
- Efficient batching

### 3. Competitor Monitoring

**Add to HEARTBEAT.md:**
```markdown
# Competitor Monitor (ежедневно в 10:00 Vienna)
Когда видишь сообщение "[RUN_COMPETITOR_MONITOR] Мониторинг конкурентов", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh activity "https://linkedin.com/in/competitor1" 10
/root/.openclaw/workspace/bin/linkedin-mcp.sh activity "https://linkedin.com/in/competitor2" 10
```
```

**What it does:**
- Monitors competitor activity
- Tracks their post engagement
- Compares with your performance
- Identifies trending topics

## Response Format

### Normal Response

```
📊 LinkedIn Analytics Report

📈 Engagement (last 20 posts):
  - Likes: 35.2 avg
  - Comments: 5.8 avg
  - Reposts: 2.1 avg
  - Engagement rate: 2.9%

🏆 Top Performing Posts:
  1. "AI automation tips" - 42 likes, 3.4% engagement
  2. "LinkedIn strategy" - 38 likes, 3.1% engagement

👍 New Likes (3):
  - Mike Johnson liked "AI automation tips"
  - Sarah Smith liked "LinkedIn strategy"
  - Tom Wilson liked "Content marketing"
```

### No Activity

```
✅ LinkedIn Check Complete

📊 Analytics (last 20 posts):
  - Average engagement: 2.9%
  - No significant changes

👍 New Likes: 0
```

### Error Response

```
⚠️ LinkedIn Check Failed

Error: Session expired

To fix:
1. cd /root/.openclaw/workspace/skills/linkedin-automation
2. ./setup-linkedin-session.sh
```

## Smart Triggers

### Only Report Changes

```markdown
# LinkedIn Smart Report (ежедневно в 9:00 Vienna)
Когда видишь сообщение "[RUN_LINKEDIN_SMART] Умный отчёт LinkedIn", выполни:
```bash
# Проверить только если есть изменения
if /root/.openclaw/workspace/bin/linkedin-mcp.sh scan-likes 25 | jq -e '.new_count > 0' > /dev/null; then
    echo "🔔 New likes detected on LinkedIn!"
    /root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20
fi
```
```

### Threshold Alerts

```markdown
# LinkedIn Threshold Alert (ежедневно)
Когда видишь сообщение "[RUN_LINKEDIN_THRESHOLD] Проверка пороговых значений", выполни:
```bash
# Только если engagement rate > 5%
ENGAGEMENT=$(/root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20 | jq -r '.averages.engagement_rate' | sed 's/%//')
if (( $(echo "$ENGAGEMENT > 5.0" | bc -l) )); then
    echo "🚀 High engagement alert: ${ENGAGEMENT}%"
fi
```
```

## Advanced Usage

### JSON Processing with jq

```bash
# Извлечь только топ посты
/root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20 | \
  jq '.top_performing[] | {url, metric, value}'

# Сравнить с предыдущим днём
/root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20 | \
  jq '.averages | {likes, comments, engagement_rate}'
```

### Multi-Session Coordination

```markdown
# Send to LinkedIn monitoring session
Когда видишь сообщение "[RUN_LINKEDIN_SESSION] Анализ LinkedIn в отдельной сессии", выполни:
```bash
sessions_send \
  --label="linkedin-monitor" \
  --message="Run full LinkedIn analysis: feed (10), analytics (20), likes scan (25)"
```
```

## Best Practices

### 1. Batch Requests

**Плохо (отдельные вызовы):**
```markdown
# 3 отдельных сообщения
[RUN_LINKEDIN_1] Feed check
[RUN_LINKEDIN_2] Analytics
[RUN_LINKEDIN_3] Likes
```

**Хорошо (один вызов):**
```markdown
# Одно сообщение - все проверки
[RUN_LINKEDIN_FULL] Полная проверка LinkedIn
```

### 2. Frequency Management

- **Feed:** Каждые 4-6 часов (не чаще!)
- **Analytics:** 1-2 раза в день
- **Likes:** Ежедневно
- **Profile Stats:** Раз в неделю

### 3. Error Handling

Всегда проверяйте сессию перед другими вызовами:
```markdown
# LinkedIn Daily Check (ежедневно)
Когда видишь сообщение "[RUN_LINKEDIN_DAILY] Полная проверка LinkedIn", выполни:
```bash
# Проверка сессии
/root/.openclaw/workspace/bin/linkedin-mcp.sh check-session

# Если ок - остальные проверки
/root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20
/root/.openclaw/workspace/bin/linkedin-mcp.sh scan-likes 25
```
```

## Summary Templates

### Template 1: Basic Daily

```markdown
# LinkedIn Analytics (ежедневно в 9:00 Vienna)
Когда видишь сообщение "[RUN_LINKEDIN_ANALYTICS] Запуск аналитики LinkedIn", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20
```

Если <2% engagement rate → предложить улучшить контент
Если >5% engagement rate → поздравить с успехом
```

### Template 2: Comprehensive

```markdown
# LinkedIn Full Check (ежедневно в 9:00 Vienna)
Когда видишь сообщение "[RUN_LINKEDIN_FULL] Полная проверка LinkedIn", выполни:
```bash
/root/.openclaw/workspace/bin/linkedin-mcp.sh check-session
/root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20
/root/.openclaw/workspace/bin/linkedin-mcp.sh scan-likes 25
```

Если есть новые лайки → проанализировать контент
Если engagement изменился >±20% → предупредить
```

### Template 3: Smart Trigger

```markdown
# LinkedIn Smart Report (ежедневно в 9:00 Vienna)
Когда видишь сообщение "[RUN_LINKEDIN_SMART] Умный отчёт LinkedIn", выполни:
```bash
# Проверить только если есть активность
RESULT=$(/root/.openclaw/workspace/bin/linkedin-mcp.sh scan-likes 25)
NEW_LIKES=$(echo "$RESULT" | jq -r '.new_count')

if [[ "$NEW_LIKES" -gt 0 ]]; then
    echo "🔔 $NEW_LIKES новых лайков на LinkedIn"
    /root/.openclaw/workspace/bin/linkedin-mcp.sh analytics 20
fi
```
```

---

**Note:** Выберите подходящий шаблон и адаптируйте под свои нужны.
