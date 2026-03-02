#!/bin/bash
# Generate OAuth URL for Gmail access with delete permissions

echo "🔗 Gmail OAuth Authorization"
echo "============================"
echo ""

# Use existing OAuth client (from gog config)
CLIENT_ID="894034812238-80tvutgc7dhd6hf2gplf63pcra8p5k60.apps.googleusercontent.com"
REDIRECT_URI="http://localhost:12345/callback"

# Scopes for Gmail modify (delete/trash support)
SCOPES="https://www.googleapis.com/auth/gmail.modify https://www.googleapis.com/auth/gmail.readonly"

# URL-encode the scopes
ENCODED_SCOPES=$(echo "$SCOPES" | sed 's/ /%20/g')

# Generate OAuth URL
AUTH_URL="https://accounts.google.com/o/oauth2/v2/auth?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&scope=${ENCODED_SCOPES}&response_type=code&access_type=offline&prompt=consent"

echo "📋 Шаги:"
echo ""
echo "1. 📋 Скопируй эту ссылку:"
echo ""
echo "$AUTH_URL"
echo ""
echo "2. 🌐 Открой её в браузере"
echo "3. ✅ Подтверди доступ к Gmail (modify + readonly)"
echo "4. 📝 Копируй authorization code из URL после редиректа"
echo "5. 📤 Пришли мне authorization code"
echo ""
echo "════════════════════════════════════════"
echo ""
echo "После того как пришлёшь code, я:"
echo "  • Обменяю его на access token"
echo "  • Сохраню refresh token"
echo "  • Настрою автоматическое обновление"
echo "  • Протестирую удаление писем"
echo ""
echo "Готово? Жду authorization code! 🎯"
