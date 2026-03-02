#!/bin/bash
# MCP Webhook для n8n
# Использование: ./mcp-n8n-webhook.sh "твой запрос"

WEBHOOK_URL="https://n8n.aaagency.at/webhook/8c0d8049-6884-4fdb-b2f1-9ec1a236c0f9"
WEBHOOK_KEY="${WEBHOOK_KEY:-}"
SESSION_ID="${OPENCLAW_SESSION_KEY:-main-session}"

# Если WEBHOOK_KEY не задан, используем placeholder (настроить!)
if [ -z "$WEBHOOK_KEY" ]; then
  WEBHOOK_KEY="your-webhook-key-here"
fi

MESSAGE="$1"

if [ -z "$MESSAGE" ]; then
  echo "❌ Укажи сообщение: ./mcp-n8n-webhook.sh 'текст запроса'"
  exit 1
fi

curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "{
    \"key\": \"$WEBHOOK_KEY\",
    \"sessionId\": \"$SESSION_ID\",
    \"message\": \"$MESSAGE\",
    \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
    \"source\": \"openclaw\"
  }" \
  -w "\n\n--- HTTP Status: %{http_code} ---\n"
