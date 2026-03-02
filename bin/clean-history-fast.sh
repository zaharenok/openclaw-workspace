#!/bin/bash
# Удаление чувствительных файлов из истории используя BFG или git-filter-repo

echo "🧹 Удаление секретов из истории git"
echo ""

# Проверка наличия инструментов
if command -v bfg &> /dev/null; then
    echo "Используем BFG Repo-Cleaner..."
    
    # Удаляем config/mcporter.json
    bfg --delete-files config/mcporter.json
    
    # Удаляем скрипты с токенами
    bfg --delete-files test-github-mcp.sh,test-github-mcp-v2.sh,check-mcp-search.sh,check-repo-mcp.sh,backup-to-github-api.sh
    
    echo "✅ BFG завершён"
    
elif command -v git-filter-repo &> /dev/null; then
    echo "Используем git-filter-repo..."
    
    # Удаляем файлы
    git-filter-repo --invert-paths \
        --path config/mcporter.json \
        --path bin/test-github-mcp.sh \
        --path bin/test-github-mcp-v2.sh \
        --path bin/check-mcp-search.sh \
        --path bin/check-repo-mcp.sh \
        --path bin/backup-to-github-api.sh
    
    echo "✅ git-filter-repo завершён"
    
else
    echo "❌ Ни BFG ни git-filter-repo не найдены"
    echo ""
    echo "Установка:"
    echo "  BFG: https://rtyley.github.io/bfg-repo-cleaner/"
    echo "  git-filter-repo: pip install git-filter-repo"
    echo ""
    echo "Или используйте встроенный метод (git filter-branch):"
    echo "  ./bin/clean-secrets-from-history.sh"
    exit 1
fi

# Очистка
echo ""
echo "🗑️  Очистка..."
git gc --prune=now --aggressive

echo ""
echo "✅ Готово! Теперь сделайте force push:"
echo "   git push origin master --force"
