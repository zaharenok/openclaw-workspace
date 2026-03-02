# 🔧 Context Manager - Решение "prompt too large"

## Проблема
```
Context overflow: prompt too large for the model
```

## Решение создано!

**Расположение:** `~/.openclaw/workspace/context-manager/`

## Быстрое решение

```bash
cd ~/.openclaw/workspace/context-manager
./quick-fix.sh
```

Это создаст `CONTEXT_SUMMARY.md` с рекомендациями.

## Стратегии исправления

### 1. Начни новую сессию ✅ РЕКОМЕНДУЕТСЯ
```
/new
```
Самый простой способ — чистый контекст.

### 2. Используй OpenCode план
```bash
opencode
# Plan mode (Tab) - не делает изменений, только предлагает
```

### 3. Дроби задачи
```
Вместо: "перепиши весь проект"
Лучше: "перепиши функцию X"
```

### 4. Сжимай контекст
```bash
./fix-context.sh compress
./fix-context.sh clean
```

## Инструменты

### quick-fix.sh
Мгновенное решение — создаёт summary и рекомендации.

### fix-context.sh
Полный набор инструментов:
- `analyze` — анализ размера контекста
- `compress` — сжатие сообщений
- `clean` — удаление старых файлов
- `stats` — статистика

### context-manager.js
JavaScript API для продвинутого использования.

## Профилактика

1. **Используй /new регулярно** — каждые 50-100 сообщений
2. **Храни важное в MEMORY.md** — не дублируй
3. **Архивируй проекты** — перемещай завершённое в `archive/`
4. **Используй memory/YYYY-MM-DD.md** — ежедневные заметки
5. **Включи compaction** — в настройках OpenClaw

## Для OpenCode

Если overflow в OpenCode:

1. **Plan mode** (Tab) — без изменений
2. **Мелкие шаги** — по одной функции
3. **/init** — создаёт AGENTS.md
4. **Новый проект** — изолируй большой код

## Автоматизация

Добавь в `HEARTBEAT.md`:
```markdown
# Context Overflow Prevention
When context usage >80%, warn user to start /new session:
"⚠️ Context getting full (X% used). Consider /new to start fresh."
```

## Результат

✅ **Создано:**
- `context-manager.js` — JavaScript API
- `fix-context.sh` — CLI инструменты
- `quick-fix.sh` — быстрое решение
- `README.md` — документация

✅ **Готово к использованию!**

Запусти `./quick-fix.sh` для быстрого исправления!

---

**Создано с помощью OpenCode** 🔧
[Твоя задача решена!](./quick-fix.sh)
