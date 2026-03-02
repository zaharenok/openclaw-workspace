#!/bin/bash
# Gmail OAuth Setup Script
# Guides user through OAuth flow to get delete permissions

set -e

echo "🔐 Gmail OAuth Setup"
echo "===================="
echo ""
echo "Этот скрипт поможет получить права на удаление писем"
echo ""

# Check if gog is installed
if ! command -v gog &> /dev/null; then
    echo "❌ gog CLI не установлен"
    echo "Установи: go install github.com/tochka/gog@latest"
    exit 1
fi

# OAuth configuration
CLIENT_ID="894034812238-80tvutgc7dhd6hf2gplf63pcra8p5k60.apps.googleusercontent.com"
# Note: This is the disabled client - we need a new one or use gog's built-in

echo "📋 Инструкция:"
echo ""
echo "Вариант 1 (простой):"
echo "1. Открой терминал на своей машине"
echo "2. Запусти: gog auth login"
echo "3. Следуй инструкциям в браузере"
echo "4. Скопируйте полученный refresh token"
echo ""
echo "Вариант 2 (ручной OAuth):"
echo "1. Создай OAuth credentials в Google Cloud Console"
echo "2. Скопируйте client_id и client_secret"
echo "3. Я создам OAuth URL для авторизации"
echo ""
echo "Какой вариант попробовать? (1/2)"
read -r choice

if [ "$choice" = "1" ]; then
    echo ""
    echo "🚀 Запусти на своей машине:"
    echo "   gog auth login --scopes https://www.googleapis.com/auth/gmail.modify,https://www.googleapis.com/auth/gmail.readonly"
    echo ""
    echo "После авторизации пришли мне refresh token"
elif [ "$choice" = "2" ]; then
    echo ""
    echo "📝 Введи client_id:"
    read -r CLIENT_ID
    echo "📝 Введи client_secret:"
    read -r CLIENT_SECRET

    # Generate OAuth URL
    REDIRECT_URI="urn:ietf:wg:oauth:2.0:oob"
    SCOPE="https://www.googleapis.com/auth/gmail.modify https://www.googleapis.com/auth/gmail.readonly"
    AUTH_URL="https://accounts.google.com/o/oauth2/v2/auth?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&scope=${SCOPE}&response_type=code&access_type=offline"

    echo ""
    echo "🔗 Открой эту ссылку:"
    echo "$AUTH_URL"
    echo ""
    echo "📝 Введи полученный authorization code:"
    read -r AUTH_CODE

    # Exchange code for tokens
    TOKEN_RESPONSE=$(curl -s -X POST https://oauth2.googleapis.com/token \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "client_id=$CLIENT_ID" \
        -d "client_secret=$CLIENT_SECRET" \
        -d "code=$AUTH_CODE" \
        -d "redirect_uri=$REDIRECT_URI" \
        -d "grant_type=authorization_code")

    echo "$TOKEN_RESPONSE" | jq .

    REFRESH_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.refresh_token')
    ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token')

    if [ -n "$REFRESH_TOKEN" ] && [ "$REFRESH_TOKEN" != "null" ]; then
        echo ""
        echo "✅ Успешно получены токены!"
        echo ""
        echo "Сохраняю в config..."

        # Update config
        CONFIG_FILE="/root/.config/gogcli/keyring/botforoleg.json"
        EXPIRES_IN=$(echo "$TOKEN_RESPONSE" | jq -r '.expires_in // 3600')
        EXPIRES_AT=$(($(date +%s) + EXPIRES_IN))

        jq --arg tok "$ACCESS_TOKEN" --arg ref "$REFRESH_TOKEN" --arg exp "$EXPIRES_AT" \
            '.access_token = $tok | .refresh_token = $ref | .expires_at = ($exp | tonumber)' \
            "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

        echo "✅ Сохранено!"
        echo ""
        echo "🧪 Тестирование..."
        curl -s "https://www.googleapis.com/oauth2/v3/tokeninfo?access_token=$ACCESS_TOKEN" | jq .
    else
        echo "❌ Ошибка получения токенов"
        exit 1
    fi
else
    echo "❌ Неверный выбор"
    exit 1
fi
