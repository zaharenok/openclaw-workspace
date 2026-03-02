# YouTube Transcription System

Автоматическая расшифровка YouTube видео через n8n webhook с сохранением в базу знаний.

## 🚀 Быстрый старт

Просто отправь мне YouTube URL, и я сделаю всё автоматически:

```
https://youtube.com/watch?v=dQw4w9WgXcQ
```

Я:
1. Отправлю запрос на n8n webhook
2. Получу оптимизированный текст
3. Сохраню в `knowledge/youtube/`
4. Покажу статистику

## 🛠️ Скрипты

### Полный workflow (рекомендуется)
```bash
./tools/youtube-workflow.sh "URL" [language]
```

### Только отправка запроса
```bash
./tools/youtube-transcribe.sh "URL" "Russian"
```

### Только сохранение
```bash
./tools/save-transcript.sh /tmp/youtube-transcribe-timestamp.json
```

## 📁 Структура файлов

```
workspace/
├── tools/
│   ├── youtube-transcribe.sh    # Отправка на webhook
│   ├── save-transcript.sh       # Сохранение в базу
│   └── youtube-workflow.sh      # Полный цикл
└── knowledge/
    └── youtube/
        └── 2026-02-02-VIDEO_ID-title.md
```

## 📝 Формат сохранения

Каждое расшифровка сохраняется как Markdown с:
- Заголовок (название видео)
- Метаданные (ID, язык, дата)
- Полный текст расшифровки
- Ссылка на оригинал

## 🌐 Поддерживаемые языки

- `Russian` (по умолчанию)
- `English`
- `German`
- Другие (зависит от настроек n8n)

## 🔧 Технические детали

**Webhook:** https://n8n.aaagency.at/webhook/9b601faa-5f51-477a-9d23-e95104ccd35d
**Token:** my-secret-token-2024
**Parser:** Python 3 (JSON extraction)

## 💡 Использование

Просто отправляй ссылки на YouTube видео в чат, и я буду их автоматически расшифровывать и сохранять!
