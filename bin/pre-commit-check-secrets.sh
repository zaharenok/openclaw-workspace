#!/bin/bash
# Pre-commit hook для проверки секретов
# Установить: cp bin/check-secrets.sh .git/hooks/pre-commit

echo "🔍 Проверка секретов перед коммитом..."

# Проверка на токены в добавленных файлах
FILES=$(git diff --cached --name-only --diff-filter=ACM)

if [ -z "$FILES" ]; then
    exit 0
fi

FOUND=0

for FILE in $FILES; do
    if [ ! -f "$FILE" ]; then
        continue
    fi
    
    # GitHub tokens
    if grep -q "ghp_[a-zA-Z0-9]\{36\}" "$FILE" 2>/dev/null; then
        echo "❌ $FILE: найден GitHub token!"
        FOUND=1
    fi
    
    # API keys
    if grep -qiE "API[_-]?KEY['\"]?\s*[:=]\s*['\"][^'\"]{10,}" "$FILE" 2>/dev/null; then
        echo "❌ $FILE: найден API key!"
        FOUND=1
    fi
    
    # Tokens
    if grep -qiE "TOKEN['\"]?\s*[:=]\s*['\"][^'\"]{20,}" "$FILE" 2>/dev/null; then
        echo "❌ $FILE: найден TOKEN!"
        FOUND=1
    fi
    
    # Passwords
    if grep -qiE "PASSWORD['\"]?\s*[:=]\s*['\"][^'\"]{8,}" "$FILE" 2>/dev/null; then
        echo "❌ $FILE: найден PASSWORD!"
        FOUND=1
    fi
done

# Проверка что .env файлы не коммитятся
for FILE in $FILES; do
    if [[ "$FILE" =~ \.env ]]; then
        echo "❌ $FILE: .env файлы не должны коммититься!"
        FOUND=1
    fi
done

if [ $FOUND -eq 1 ]; then
    echo ""
    echo "❌ Коммит отклонён! Найдены секреты."
    echo ""
    echo "Что делать:"
    echo "1. Удалить секреты из файлов"
    echo "2. Добавить в .gitignore если нужно"
    echo "3. Использовать переменные окружения вместо хардкода"
    exit 1
fi

echo "✅ Секреты не найдены"
exit 0
