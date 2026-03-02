#!/bin/bash

# Chat Personas - Auto persona for each chat

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHAT_FILE="$HOME/.openclaw/workspace/chat-personas.json"

case "${1:-help}" in
  detect)
    TITLE="$2"
    CHAT_ID="${3:-manual}"

    if [ -z "$TITLE" ]; then
      echo "Usage: ./chat-personas.sh detect \"Chat Title\" [chat_id]"
      exit 1
    fi

    echo "🔍 Detecting persona for: $TITLE"
    node "$SCRIPT_DIR/chat-personas.js" detect "$TITLE" "$CHAT_ID"
    ;;

  set)
    CHAT_ID="$2"
    PERSONA="$3"
    EMOJI="${4:-🤖}"

    if [ -z "$CHAT_ID" ] || [ -z "$PERSONA" ]; then
      echo "Usage: ./chat-personas.sh set <chat_id> <persona> [emoji]"
      exit 1
    fi

    node "$SCRIPT_DIR/chat-personas.js" set "$CHAT_ID" "$PERSONA" "$EMOJI"
    echo "✅ Persona set!"
    ;;

  list)
    node "$SCRIPT_DIR/chat-personas.js" list
    ;;

  help|*)
    cat << EOF
Chat Personas - Auto-detect persona for each chat

Usage: ./chat-personas.sh [command]

Commands:
  detect "<title>" [id]  Auto-detect persona from chat title
  set <id> <persona>     Manually set persona for chat
  list                    List all configured chats

Auto-detected patterns:
  💻 Code      - код, code, programming, develop
  🏃 Health    - здоровье, health, фитнес, fitness
  💼 Business  - бизнес, business, стратегия, strategy
  🎨 Creative  - творч, creative, design, идеи
  🔧 OpenCode  - opencode, devops, infra

Examples:
  ./chat-personas.sh detect "Код Ассистент"
  ./chat-personas.sh set -1001234567890 code 💻
  ./chat-personas.sh list
EOF
    ;;
esac
