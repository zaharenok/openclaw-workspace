# HEARTBEAT.md

# Keep this file minimal - only essential periodic tasks

# GitHub Backup (smart - только если есть изменения)
Когда видишь сообщение "[RUN_GITHUB_BACKUP] Запуск бэкапа на GitHub", выполни:
```bash
/home/node/.openclaw/workspace/bin/backup-to-github.sh
```

# GitHub Memory Pull (ежедневно в 08:00 UTC)
Когда видишь сообщение "[RUN_GIT_PULL] Запуск обновления памяти с GitHub", выполни:
```bash
cd /root/.openclaw/workspace && \
if [ -n "$(git status --porcelain)" ]; then \
  git add -A && \
  git commit -m "chore: auto-commit before git pull $(date -u +"%Y-%m-%d %H:%M UTC")" && \
  git push origin main; \
fi && \
git pull origin main
```

# Repo Maintenance (ежедневно в 07:00 UTC, smart - только если есть изменения)
Когда видишь сообщение "[RUN_REPO_MAINTENANCE] Запуск синхронизации и сканирования репо", выполни:
```bash
/home/node/.openclaw/workspace/bin/repo-maintenance.sh
```

# Security Scan (каждые 3 часа)
Когда видишь сообщение "[RUN_SECURITY_SCAN]", выполни:
```bash
/home/node/.openclaw/workspace/bin/security-scan.sh
```

# Add tasks below when you want the agent to check something periodically.
