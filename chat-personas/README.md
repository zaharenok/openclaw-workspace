# Chat Personas - Авто-определение личности для чатов

## Как это работает

Система автоматически определяет какая persona нужна в чате основываясь на:
- Названии чата
- Первых сообщениях
- Явной настройке

## Установка

```bash
cd ~/.openclaw/workspace/chat-personas
chmod +x chat-personas.sh
```

## Использование

### Авто-определение
```bash
./chat-personas.sh detect "Код Ассистент"
# Output: Detected: 💻 code
```

### Ручная настройка
```bash
./chat-personas.sh set <chat_id> code 💻
```

### Список всех чатов
```bash
./chat-personas.sh list
```

## Авто-определяемые паттерны

| Emoji | Persona | Паттерны |
|-------|---------|----------|
| 💻 | code | код, code, programming, develop |
| 🏃 | health | здоровье, health, фитнес, fitness, спорт |
| 💼 | business | бизнес, business, стратегия, strategy, работа |
| 🎨 | creative | творч, creative, design, идеи |
| 🔧 | opencode | opencode, devops, infra |

## Интеграция

Добавь в `HEARTBEAT.md`:
```markdown
# Auto Persona Detection
When message received, check chat title/name and auto-set persona.
Use: cd ~/workspace/chat-personas && ./chat-personas.sh detect "<title>"
```

## Примеры

**Чат "Код Ассистент"** → 💻 Code Expert
**Чат "Мой тренер"** → 🏃 Health Coach
**Чат "Бизнес консультант"** → 💼 Business Advisor

## Конфигурация

Сохраняется в `~/.openclaw/workspace/chat-personas.json`:
```json
{
  "version": 1,
  "chats": {
    "-1001234567890": {
      "persona": "code",
      "emoji": "💻",
      "autoDetected": true
    }
  }
}
```

---
Создано для multi-persona чатов! 🎯
