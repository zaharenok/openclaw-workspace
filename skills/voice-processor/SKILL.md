# Voice Processor - SKILL.md

**Название:** Voice Processor for Telegram
**Описание:** Автоматическая транскрибация голосовых сообщений + ответы + очистка

## Что делает

1. 🎤 **Принимает** голосовые сообщения из Telegram
2. 📝 **Транскрибирует** через OpenAI Whisper API
3. 💬 **Отправляет** текст в чат
4. 🤖 **Отвечает** на сообщение
5. 🗑️ **Удаляет** файлы через 24 часа

## Компоненты

### 1. Processor Script
`scripts/processor.sh` — основная логика обработки

### 2. Transcript Storage
`transcripts/` — временные файлы транскрипций

### 3. Cleanup System
Автоматическое удаление через 24 часа

## Использование

### Ручное тестирование:
```bash
./scripts/processor.sh process /path/to/voice.ogg msg_123
./scripts/processor.sh cleanup  # Удаление старых файлов
```

### Автоматизация (через cron):
Добавить в HEARTBEAT.md или cron job для периодической очистки.

## Требования

- ✅ OpenAI API ключ (уже настроен)
- ✅ OpenAI Whisper API skill (уже установлен)
- ✅ bash + curl (уже есть)

## Файлы

- `scripts/processor.sh` — основной скрипт
- `transcripts/*.txt` — транскрипции
- `transcripts/cleanup_queue.txt` — очередь удаления
- `transcripts/processor.log` — логи

## Интеграция с Telegram

OpenClaw автоматически загружает голосовые сообщения в `/tmp/` или workspace.
При получении голосового сообщения:
1. Вызвать `processor.sh process <file> <msg_id>`
2. Получить текст транскрипции
3. Отправить в чат + ответить
4. Очистка произойдёт автоматически через 24ч

## Настройка

Редактируйте переменные в `scripts/processor.sh`:
- `KEEP_HOURS=24` — время хранения (часы)
- `TRANSCRIPTS_DIR` — папка для хранения

---

**Создано:** 2026-01-30
**Автор:** Code Expert для Oleg
