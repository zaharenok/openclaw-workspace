#!/bin/bash
#
# Telegram YouTube Monitor Wrapper
# Мониторинг Telegram каналов для YouTube видео
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/telegram-youtube-monitor.py"

# Проверка Python зависимостей
check_dependencies() {
    if ! python3 -c "import requests" 2>/dev/null; then
        echo "⚠️  Installing missing dependencies..."
        pip3 install requests
    fi
}

# Показать помощь
show_help() {
    cat << EOF
🎬 Telegram YouTube Monitor

Читает сообщения из Telegram канала, извлекает YouTube ссылки 
и отправляет в n8n для транскрибации.

Использование:
  $0 <channel_id> [limit]

Аргументы:
  channel_id  Telegram channel ID (@channelname or numeric ID)
  limit       Количество сообщений для проверки (default: 10)

Примеры:
  $0 @telegram_channel
  $0 @telegram_channel 20
  $0 -1234567890 50

EOF
}

# Main
check_dependencies

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

if [[ -z "$1" ]]; then
    show_help
    exit 1
fi

python3 "$PYTHON_SCRIPT" "$@"
