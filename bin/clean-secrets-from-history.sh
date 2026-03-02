#!/bin/bash
# Удаление секретов из истории git

echo "⚠️  ВНИМАНИЕ: Это перепишет историю git!"
echo ""
echo "Что будет сделано:"
echo "1. Удалено config/mcporter.json из всей истории"
echo "2. Удалены скрипты с захардкоденными токенами"
echo "3. Все коммиты будут пересозданы"
echo ""
echo "⚠️  Потребуется force push: git push --force"
echo ""

read -p "Продолжить? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Отменено"
    exit 0
fi

# Резервная копия
BACKUP_DIR="backup-before-cleanup-$(date +%Y%m%d-%H%M%S)"
echo ""
echo "📦 Создание резервной копии в $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
cp -r . "$BACKUP_DIR/"

# Удаление файлов из истории с помощью git filter-branch
echo ""
echo "🧹 Очистка истории..."

# Удаляем config/mcporter.json из истории
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch config/mcporter.json' \
  --prune-empty --tag-name-filter cat -- --all

# Удаляем скрипты с токенами
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch bin/test-github-mcp.sh bin/test-github-mcp-v2.sh bin/check-mcp-search.sh bin/check-repo-mcp.sh bin/backup-to-github-api.sh' \
  --prune-empty --tag-name-filter cat -- --all

# Очистка
echo ""
echo "🗑️  Очистка reflog..."
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo ""
echo "✅ История очищена!"
echo ""
echo "Следующие шаги:"
echo "1. Проверьте результат: git log"
echo "2. Force push на GitHub:"
echo "   git push origin master --force"
echo "3. Резервная копия в: $BACKUP_DIR"
echo ""
echo "⚠️  Если у вас есть клоны репозитория, им нужно сделать:"
echo "   git fetch origin"
echo "   git reset --hard origin/master"
