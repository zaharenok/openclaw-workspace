# HEARTBEAT.md

# Voice Processor Cleanup
Когда видишь сообщение "[RUN_CLEANUP] voice-processor:", выполни:
```bash
/home/node/.openclaw/workspace/skills/voice-processor/scripts/processor.sh cleanup
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
git pull origin master
```

# GitHub Backup (smart - только если есть изменения)
Когда видишь сообщение "[RUN_GITHUB_BACKUP] Запуск бэкапа на GitHub", выполни:
```bash
/home/node/.openclaw/workspace/bin/backup-to-github.sh
```
**Улучшения:**
- ✅ Проверяет изменения ПЕРВЫМ делом
- ✅ Если нет изменений - выходит молча
- ✅ Показывает какие файлы изменились
- ✅ Только потом делает pull/commit/push

# Repo Maintenance (ежедневно в 07:00 UTC, smart - только если есть изменения)
Когда видишь сообщение "[RUN_REPO_MAINTENANCE] Запуск синхронизации и сканирования репо", выполни:
```bash
/home/node/.openclaw/workspace/bin/repo-maintenance.sh
```
**Что делает:**
1. Синхронизирует все репо в ~/repos/ (git pull)
2. Обновляет memory/GITHUB_REPOSITORIES.md с историей изменений
3. Сканирует все репо на утекшие секреты (trufflehog)
4. Генерирует 2 отчёта в reports/ (изменения + секреты)

**Улучшения:**
- ✅ Проверяет изменения ПЕРВЫМ делом
- ✅ Если во всех репо нет изменений - выходит молча
- ✅ Генерирует отчёты только когда есть что показывать
- ✅ При нахождении секретов - возвращает exit code 1

# Secrets Check (smart - только если файлы изменились)
Периодически (раз в день) проверяй наличие секретов:
```bash
/home/node/.openclaw/workspace/bin/check-secrets.sh
```
**Улучшения:**
- ✅ Проверяет git state перед сканированием
- ✅ Если файлы не менялись - пропускает проверку
- ✅ Сохраняет состояние между запусками
- ✅ При нахождении секретов - повторит проверку в следующий раз

Если найдены - немедленно сообщи пользователю!

# Новости Австрии
Когда видишь сообщение "[RUN_NEWS_AUSTRIA]", выполни:
```bash
/home/node/.openclaw/workspace/bin/collect-austria-news.py
```

# Gmail Check (ежедневно Пн-Пт 9:00-17:00 Vienna)
Когда видишь сообщение "[RUN_GMAIL_CHECK] Запуск проверки почты botforoleg@gmail.com", выполни:
```bash
/root/.openclaw/workspace/bin/check-gmail.sh
```
**Примечание:** gog CLI отключен (OAuth client disabled). Используется wrapper скрипт с OAuth2 refresh token.

# Pete Steinberger Newsletter Monitor
Когда приходят письма от peter@steipete.me (What's new with Pete), выполни:
```bash
/root/.openclaw/workspace/bin/check-pete-newsletter.sh
```
Этот скрипт:
- 📰 Проверяет новые письма от Pete
- 📝 Извлекает заголовок и дату
- ✂️ Удаляет HTML и ссылки
- 📤 Отправляет краткий дайджест

**Тема:** AI-powered tools from Swift roots to web frontiers
**Частота:** Когда приходят письма (не по расписанию)

# Email Replies Check (ежедневно каждые 4 часа)
Проверять почту olegzakharchenko@gmail.com на ответы от отслеживаемых адресов:
```bash
python3 /tmp/check_email_replies.py
```
Список отслеживаемых адресов: `.email-tracking/waiting-replies.md`

Этот скрипт автоматически:
- 📰 Собирает новости с 7 источников (ORF, Kurier, Heute, DiePresse, KleineZeitung, Nachrichten, OE24)
- 🎯 Фокусируется на социально-экономических новостях
- 🎭 Включает курьезные случаи
- 🖼️ Извлекает картинки (og:image)
- 🌍 Генерирует keywords на 3 языках (DE/EN/RU)
- 📈 Добавляет trending scores
- 📤 Отправляет enriched JSON на n8n webhook

**Категории:** экономика, общество, политика, криминал, курьёзы, спорт
**Вывод:** 10-15 свежих статей с полным контентом и метаданными
**Webhook:** https://n8n.aaagency.at/webhook/bd80e8cd-1a64-46ee-98ac-1f4299b9e963

# Security Scan (каждые 3 часа)
Автоматическая проверка безопасности каждые 3 часа:
```bash
/home/node/.openclaw/workspace/bin/security-scan.sh
```
**Что проверяет:**
- Криптомайнеры (Sofia, xmrig, minerd, cgminer)
- CPU steal time (>50% = майнер на host node)
- Подозрительные файлы (/tmp, /var, /root)
- Cron задачи
- SSH brute force атаки
- Необычные открытые порты
- Load average (>10 = проблема)

**При нахождении угроз** — exit code 1 + алерт в /tmp/security-scan-alerts.txt

# Security Audit (еженедельно)
Периодически (раз в неделю) проверяй безопасность VPS:
```bash
openclaw security audit --deep
```

Использовать чеклист из `docs/vps-security-audit-2026-02-11.md` для анализа результатов.

**Что проверять:**
- Network exposure (gateway.bind, открытые порты)
- Authentication (auth.mode, токены)
- Access control (dmPolicy, allowFrom)
- File permissions (700/600 для секретов)
- Skills auth files (find ~/.openclaw/skills/ -name "auth.json" -exec ls -la {} \;)

**При нахождении проблем** — немедленно сообщи пользователю!

# Voice Messages Cleanup (ежедневно)
Очищать старые голосовые сообщения чтобы не забивать память:
```bash
# Удалить голосовые старше 1 дня
find ~/.openclaw/media/inbound/ -name "*.ogg" -mtime +1 -delete

# Или старше 12 часов
find ~/.openclaw/media/inbound/ -name "*.ogg" -mmin +720 -delete

# Проверить размер директории
du -sh ~/.openclaw/media/
```

**Примечание:** Удалять только прослушанные/обработанные сообщения!

# Smart Cron Runner (универсальная обёртка)
Для любой периодической задачи можно использовать smart-cron-runner:
```bash
/home/node/.openclaw/workspace/bin/smart-cron-runner.sh <task-name> <script-path> [args...]
```
**Что делает:**
- Сохраняет git state между запусками
- Запускает задачу только если файлы изменились
- Пропускает задачу если state не изменился
- При ошибке не сохраняет state (повторит в следующий раз)

**Примеры:**
```bash
# Github backup через smart runner
smart-cron-runner.sh github-backup bin/backup-to-github.sh

# Secrets check через smart runner
smart-cron-runner.sh secrets-check bin/check-secrets.sh

# Repo maintenance через smart runner
smart-cron-runner.sh repo-maintenance bin/repo-maintenance.sh
```

# Keep this file minimal - only essential periodic tasks

# Context Overflow Prevention
When context usage >80%, warn user to start /new session:
"⚠️ Context getting full (X% used). Consider /new to start fresh."
