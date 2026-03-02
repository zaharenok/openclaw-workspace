# TOOLS.md - Local Notes

<<<<<<< HEAD
Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.
=======
Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.
>>>>>>> 24a5d65408d2c3c4c7006b937305cc132600895e

## What Goes Here

Things like:
<<<<<<< HEAD
=======

>>>>>>> 24a5d65408d2c3c4c7006b937305cc132600895e
- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
<<<<<<< HEAD
### Timezone (IMPORTANT!)
- User timezone: UTC+1 (Вена / Austria)
- When user says time = ALWAYS their Vienna time
- All cron jobs scheduled in Vienna time
- Current: 10:03 Vienna = 09:03 UTC

### Cameras
=======
### Cameras

>>>>>>> 24a5d65408d2c3c4c7006b937305cc132600895e
- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH
<<<<<<< HEAD
- home-server → 192.168.1.100, user: admin

### TTS
=======

- home-server → 192.168.1.100, user: admin

### TTS

>>>>>>> 24a5d65408d2c3c4c7006b937305cc132600895e
- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.
<<<<<<< HEAD

## MCP Webhooks

### OpenClaw Webhook Server
- **URL:** http://srv1303227.hstgr.cloud:5679/webhook
- **Port:** 5679 (internal)
- **Token:** openclaw-webhook-2026
- **Status:** ✅ Running (systemd service)
- **Log file:** /tmp/openclaw-webhooks.jsonl

**How to send webhooks:**
```bash
# Using wrapper script
webhook-send "Your message here" "source_name"

# Using Python client
python3 /root/.openclaw/workspace/tools/send-webhook.py "Message" "source"

# Using curl directly
curl -X POST http://localhost:5679/webhook \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Token: openclaw-webhook-2026" \
  -d '{"message":"Your text","source":"my_app"}'
```

**Request format:**
```json
{
  "message": "Text to send to OpenClaw",
  "source": "app_name",
  "timestamp": "2026-02-13T12:00:00Z"
}
```

**Service management:**
```bash
# Check status
systemctl status openclaw-webhook.service

# Restart
systemctl restart openclaw-webhook.service

# View logs
journalctl -u openclaw-webhook -f
```

### n8n Webhook (context7)
- **URL:** https://n8n.aaagency.at/webhook/8c0d8049-6884-4fdb-b2f1-9ec1a236c0f9
- **Purpose:** MCP-сервер для обработки запросов через n8n
- **Auth:** WEBHOOK_KEY (env variable)
- **Script:** `~/workspace/tools/mcp-n8n-webhook.sh "запрос"`
- **Connected:** context7

**Request format:**
```json
{
  "key": "WEBHOOK_KEY",
  "sessionId": "текущая-сессия",
  "message": "текст запроса",
  "timestamp": "2026-01-30T18:00:00Z",
  "source": "openclaw"
}
```

**Usage:**
```bash
# Через скрипт
./tools/mcp-n8n-webhook.sh "покажи погоду"

# Прямой curl
curl -X POST https://n8n.aaagency.at/webhook/8c0d8049-6884-4fdb-b2f1-9ec1a236c0f9 \
  -H "Content-Type: application/json" \
  -d '{"key":"XXX","sessionId":"main","message":"запрос"}'
```

## 🚨 Context Overflow - Quick Fixes

Когда opencode падает с "prompt too large":

**Быстро:**
```bash
# Автоматическое ограничение
./bin/smart-opencode ./project "задача"

# Вручную: только важные файлы
opencode run "Сосредоточься на: main.ts, auth.ts, api.ts"
```

**Детали:** `docs/context-management.md`


## 📱 Telegram Size Limits

Если ответ >4000 символов, не дойдет до Telegram.

**Решение:**
```bash
# Автоматическая разбивка
./bin/chunk-message "длинный текст"

# Или вручную с метками
"Часть 1/3: текст...
⏳
Часть 2/3: текст...
⏳
Часть 3/3 (конец): текст..."
```

**Подробно:** `docs/telegram-chunking.md`

## 🎬 YouTube Transcription

Система для получения расшифровки YouTube видео через n8n webhook.

**Webhook URL:**
```
http://76.13.128.240:5678/webhook/9b601faa-5f51-477a-9d23-e95104ccd35d
```

**Скрипты:**
```bash
# Полный workflow (рекомендуется)
./tools/youtube-workflow.sh "https://youtube.com/watch?v=VIDEO_ID" [language]

# Только отправка запроса
./tools/youtube-transcribe.sh "URL" "Russian"

# Только сохранение (если есть JSON ответ)
./tools/save-transcript.sh /tmp/youtube-transcribe-timestamp.json
```

**База знаний:** `workspace/knowledge/youtube/`

**Поддерживаемые языки:** Russian (default), English, German, etc.

**Auth:** Token "my-secret-token-2024" (hardcoded in script)

## 🔧 Telegram Bot - Node 22 + IPv6 Fix

**Проблема:** Telegram polling не работает на Node 22+ из-за проблем с IPv6.

**Решение:**
1. Добавить в `/etc/hosts`:
```bash
echo "149.154.166.110 api.telegram.org" >> /etc/hosts
```

2. Добавить в `~/.openclaw/openclaw.json`:
```json
{
  "channels": {
    "telegram": {
      "network": {
        "autoSelectFamily": true
      }
    }
  }
}
```

3. Рестарт gateway:
```bash
systemctl --user restart openclaw-gateway.service
```

**Почему это нужно:**
- Node 22+ строгий к AbortSignal
- IPv6 DNS возвращает IPv6 адрес, но egress может не работать
- `autoSelectFamily` включает Happy Eyeballs для fallback на IPv4

**Проверка:**
```bash
# Проверить DNS
dig +short api.telegram.org A
dig +short api.telegram.org AAAA

# Проверить что bot забирает сообщения
curl -s "https://api.telegram.org/bot<TOKEN>/getUpdates" | python3 -m json.tool
# Если result: [] - значит OpenClaw забирает (хорошо!)
```


## OpenClaw HTTPS Webhook

### OpenClaw Webhook Server (HTTPS) - NEW!
- **URL:** https://srv1303227.hstgr.cloud:8443/webhook
- **Port:** 8443 (HTTPS with SSL)
- **Token:** openclaw-webhook-2026
- **Status:** ✅ Running (systemd service, HTTPS enabled)
- **SSL:** Self-signed certificate (use -k with curl)
- **Log file:** /tmp/openclaw-webhooks.jsonl

**How to send webhooks:**
```bash
# Using wrapper script (recommended)
webhook-send "Your message here" "source_name"

# Using Python client
python3 /root/.openclaw/workspace/tools/send-webhook.py "Message" "source"

# Using curl directly (use -k for self-signed cert)
curl -k -X POST https://srv1303227.hstgr.cloud:8443/webhook \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Token: openclaw-webhook-2026" \
  -d '{"message":"Test","source":"my_app"}'
```

**Request format:**
```json
{
  "message": "Text to send to OpenClaw",
  "source": "app_name",
  "timestamp": "2026-02-13T13:00:00Z"
}
```

**Service management:**
```bash
# Check status
systemctl status openclaw-webhook.service

# Restart
systemctl restart openclaw-webhook.service

# View logs
journalctl -u openclaw-webhook -f
```

**Security:** Basic token auth + SSL. For production, upgrade to Let's Encrypt certificate.

=======
>>>>>>> 24a5d65408d2c3c4c7006b937305cc132600895e
