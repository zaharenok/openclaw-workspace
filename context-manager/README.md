# Context Manager - Решение "prompt too large"

**Проблема:** `Context overflow: prompt too large for the model`

**Решение:** Автоматическое сжатие и управление контекстом

## Установка

```bash
cd ~/.openclaw/workspace/context-manager
chmod +x fix-context.sh
npm init -y  # Если нужно
```

## Использование

### Анализ контекста
```bash
./fix-context.sh analyze
```

### Сжатие контекста
```bash
./fix-context.sh compress
```

### Очистка старых файлов
```bash
./fix-context.sh clean
```

### Статистика
```bash
./fix-context.sh stats
```

## API (JavaScript)

```javascript
const ContextManager = require('./context-manager.js');

const manager = new ContextManager({
  maxTokens: 200000,
  compressionRatio: 0.5,
  debug: true
});

// Анализ
const stats = manager.analyze(context);
console.log(stats);

// Сжатие
const compressed = await manager.compressMessages(messages, {
  keepRecent: 20,
  summarizeThreshold: 40
});

// Удаление избыточности
const cleaned = manager.removeRedundancy(context);

// Оптимизация system prompt
const optimized = manager.optimizeSystemPrompt(systemPrompt);

// Полное решение
const result = await manager.fixContextOverflow(context);
```

## Стратегии

1. **Remove Redundancy** - Удаляет дубликаты сообщений
2. **Summarize** - Суммирует старые сообщения
3. **Optimize** - Оптимизирует системный промпт
4. **Chunk** - Разбивает большие запросы

## Интеграция с OpenClaw

Добавь в `HEARTBEAT.md`:
```markdown
# Context Overflow Prevention
Когда видишь "context overflow", выполни:
cd ~/.openclaw/workspace/context-manager
./fix-context.sh analyze
```

## Для OpenCode

Если overflow происходит в OpenCode:

1. **Используй Plan mode** — не меняет код, только предлагает
2. **Дроби задачи** — smaller steps = less context
3. **/init** — создаёт AGENTS.md, фокусирует контекст
4. **Новый проект** — изолируй большой код

## Автоматизация

Добавь в cron:
```bash
# Еженедельная очистка
0 2 * * 0 ~/.openclaw/workspace/context-manager/fix-context.sh clean
```

## Tips

- Используй `/new` для новых сессий регулярно
- Храни только важное в MEMORY.md
- Архивируй старые проекты
- Включи compaction в настройках

---
Создано с помощью OpenCode 🔧
