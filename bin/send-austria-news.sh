#!/bin/bash
# 🇦🇹 Austria News Collector & Email Sender
# Собирает новости через RSS и отправляет на email

VENV="/root/.openclaw/workspace/knowledge/poker/venv/bin/python"
WORKSPACE="/root/.openclaw/workspace"

echo "🇦🇹 Starting Austria news collection..."

# Собираем новости через RSS и сохраняем в JSON
cd "$WORKSPACE"
$VENV bin/collect-austria-news.py 2>/tmp/collector.log | tee /tmp/collector-output.txt

# Check if JSON was created
if [ -f /tmp/news-articles.json ]; then
    echo "✅ Articles saved to JSON"
    
    # Отправляем на email
    echo "📧 Sending news to olegzakharchenko@gmail.com..."
    $VENV bin/send-austria-news-email.py
else
    echo "❌ No articles file created"
    echo "📋 Collector output:"
    cat /tmp/collector-output.txt
    exit 1
fi

echo "✅ Done! Check your inbox."

