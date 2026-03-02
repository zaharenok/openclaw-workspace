# OpenClaw Bot Soul 🤖

> Личная душа и память OpenClaw AI ассистента с персонализированными навыками и автоматическими бэкапами.

## 📋 О проекте

Это workspace репозиторий OpenClaw - AI ассистента с системой персонализаций (personas), навыками (skills) и автоматическими бэкапами на GitHub.

**Владелец:** zaharenok (Vienna)  
**Создан:** 2025-01-30  
**Лицензия:** MIT

## 🎯 Что внутри

### Персонализации (Personas)
- **Orchestrator** - базовая координирующая личность
- **Health Coach** 🏃 - здоровье, фитнес, питание
- **Business Advisor** 💼 - стратегия, бизнес-решения
- **Creative Partner** 🎨 - креатив, идеи, сторителлинг
- **Code Expert** 💻 - программирование, отладка
- **OpenCode Manager** 🔧 - управление OpenCode окружением

### Навыки (Skills)
- **bluebubbles** - канал для интеграции с iMessage
- **coding-agent** - управление Codex CLI, Claude Code, OpenCode
- **openai-image-gen** - генерация изображений через OpenAI
- **openai-whisper-api** - транскрипция аудио через Whisper
- **skill-creator** - создание новых навыков
- **weather** - погода без API ключа

### Инструменты
- `bin/backup-to-github.sh` - автоматический бэкап на GitHub
- `bin/chunk-message` - разбивка длинных сообщений для Telegram
- `bin/smart-opencode` - умный запуск OpenCode с контролем контекста
- `tools/mcp-n8n-webhook.sh` - webhook для n8n интеграций

## 🔄 Что нового

### Последние изменения

**2026-01-30 21:30:10**
- ✅ Автоматический бэкап (2 файлов изменено)
- 📝 Изменённые файлы:
  - README.md
  - docs/github-mcp-tools.md
## 📦 Автоматические бэкапы

**Расписание:** Каждые 6 часов (00:00, 06:00, 12:00, 18:00 UTC)  
**Репозиторий:** https://github.com/zaharenok/Openclaw_bot_soul  
**Метод:** GitHub MCP API + git push

### Ручной бэкап
```bash
./bin/backup-to-github.sh
```

## 🛠️ Структура проекта

```
.
├── AGENTS.md           # Рабочая директория агента
├── SOUL.md             # Личность и поведение (Orchestrator)
├── MEMORY.md           # Долгосрочная память
├── USER.md             # Информация о пользователе
├── TOOLS.md            # Локальные заметки и настройки
├── HEARTBEAT.md        # Периодические задачи
├── IDENTITY.md         # Кто я?
├── README.md           # Этот файл
├── bin/                # Исполняемые скрипты
├── skills/             # Навыки и персонализации
│   ├── health-coach/
│   ├── business-advisor/
│   ├── creative-partner/
│   ├── code-expert/
│   └── opencode/
├── tools/              # Инструменты интеграции
├── docs/               # Документация
├── config/             # Конфигурация (mcporter)
└── memory/             # Дневниковые записи по датам
```

## 🔧 GitHub MCP

Настроена интеграция с GitHub MCP сервером:

**Доступные инструменты:** 37  
**Категории:**
- 📁 Репозитории: create, search, fork
- 🔀 Ветки и коммиты: create, list, push
- 📄 Файлы: read, create, update, delete
- 🐛 Issues: list, search, create, comment
- 🔀 Pull Requests: create, merge, review
- 🔍 Поиск: code, issues, users
- 🏷️ Releases и теги

**Проверка инструментов:**
```bash
./bin/list-github-tools.sh
```

## 📝 Заметки

### Контекст и память
- **MEMORY.md** - долгосрочная память (загружается только в main session)
- **memory/YYYY-MM-DD.md** - дневниковые записи по датам
- **Heartbeat проверки** - обновляют память каждые несколько дней

### Управление контекстом
- Максимальный размер контекста: зависит от модели
- При >80% использования - предупреждение о /new session
- Smart-opencode для больших проектов

### Telegram лимиты
- Максимум 4000 символов на сообщение
- Используй `chunk-message` для разбивки

## 🚀 Быстрый старт

1. **Клонирование:**
   ```bash
   git clone https://github.com/zaharenok/Openclaw_bot_soul.git
   cd Openclaw_bot_soul
   ```

2. **Структура памяти уже настроена** - просто работай

3. **Для автоматических бэкапов** - настрой GitHub токен (см. docs/github-backup-setup.md)

## 📚 Документация

- `docs/github-backup-setup.md` - настройка GitHub бэкапов
- `docs/github-mcp-check.md` - проверка GitHub MCP
- `docs/context-management.md` - управление контекстом
- `docs/telegram-chunking.md` - работа с Telegram

## 🔐 Безопасность

- ⚠️ Никогда не коммить `.env.github` или токены
- `.gitignore` настроен правильно
- GitHub токен хранится в `config/mcporter.json`
- MEMORY.md загружается только в приватных сессиях

## 📊 Статистика

- **Персонализаций:** 6
- **Навыков:** 6
- **Скриптов:** 8+
- **Документация:** полная
- **Автобэкап:** каждые 6 часов

---

*Создано с ❤️ OpenClaw AI Assistant*
*Автоматически обновляется при каждом бэкапе*
