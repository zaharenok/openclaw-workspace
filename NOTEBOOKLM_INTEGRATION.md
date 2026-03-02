# NotebookLM Integration Guide

## 📋 Overview

NotebookLM теперь интегрирован в brainstorming personas для получения контекста и исследований.

## 🎯 Когда использовать

### Creative Partner (`[creative]`)
- Изучение новых доменов (тренды, технологии, индустрии)
- Получение research-backed идей (поведение пользователей, конкурентный ландшафт)
- Fact-based креатив (статистика, кейсы, примеры)
- Проверка предположений

### Business Advisor (`[business]`)
- Исследование рынков и индустрии
- Анализ конкурентной среды
- Понимание поведения пользователей
- Валидация бизнес-предположений

## 🚀 Как использовать

### Вариант 1: Прямой запрос
```bash
nlm query notebook 13fdd598-2eec-4dcb-a884-fe9141e693e8 "твой вопрос"
```

### Вариант 2: Через MCP (для AI)
```bash
mcporter call notebooklm-mcp.notebook_query \
  notebook_id="13fdd598-2eec-4dcb-a884-fe9141e693e8" \
  query="твой вопрос"
```

### Вариант 3: С алиасом (после настройки)
```bash
# Сначала создать алиас (нужна авторизация)
nlm alias set brainstorm 13fdd598-2eec-4dcb-a884-fe9141e693e8

# Затем использовать
nlm query notebook brainstorm "твой вопрос"
```

## 💡 Примеры запросов

### Для креативных идей:
- "What are emerging trends in sustainable packaging?"
- "How do Gen Z consumers discover new products?"
- "Что делает успешные вирусные маркетинговые кампании?"
- "Examples of gamification in productivity apps"

### Для бизнес-анализа:
- "Key success factors for SaaS MVP launches"
- "How do freemium models convert users to paid?"
- "Competitive landscape: AI-powered productivity tools"
- "User acquisition strategies for B2C mobile apps"

## 📝 Workflow

1. **Persona активируется** → `[creative]` или `[business]`
2. **Получает запрос** от пользователя
3. **Если нужно исследование** → Query NotebookLM для контекста
4. **Анализирует результаты** → Использует frameworks (80/20, SWOT, etc.)
5. **Генерирует идеи** → На основе research + frameworks

## 🔧 Настройка

### Авторизация (для CLI)
```bash
nlm login
```

### Проверка статуса
```bash
# Список ноутбуков
nlm list notebooks

# Детали ноутбука
nlm get notebook 13fdd598-2eec-4dcb-a884-fe9141e693e8
```

## 📚 Доступные инструменты MCP

- `notebook_query` — Задать вопрос по источникам
- `research_start` — Глубокий research (web/Drive)
- `notebook_create` — Создать новый ноутбук
- `source_add` — Добавить источники (URL, текст, файлы)
- `studio_create` — Создать artifacts (audio, video, report, mindmap)

## 🎨 Примеры интеграции

### Scenario: Brainstorming app features
```
User: "Придумай функции для fitness app"

Creative Partner:
1. Query: "What are trending features in fitness apps 2024?"
2. Query: "What users hate about current fitness apps?"
3. Generate ideas based on research
4. Apply creative frameworks (flip assumptions, combine concepts)
```

### Scenario: Market analysis
```
User: "Стоит ли входить на рынок mediation apps?"

Business Advisor:
1. Query: "Market size and growth for meditation apps"
2. Query: "Competitive landscape: Headspace, Calm, others"
3. Query: "User acquisition costs in wellness apps"
4. Apply strategic frameworks (opportunity cost, 80/20)
5. Give recommendation with next steps
```

## ⚡ Tips

- **Research first, brainstorm second** — Получи контекст, затем генерируй идеи
- **Use specific queries** — Лучше "features users hate" чем "what do users think"
- **Combine multiple queries** — Тренды + конкурентный анализ + user pain points
- **Validate assumptions** — Проверяй свои догадки через NotebookLM
- **Keep it conversational** — NotebookLM работает как исследовательский ассистент

## 🚨 Limitations

- NotebookLM требует авторизации Google
- Работает с источниками, которые добавлены в ноутбук
- Ответы зависят от качества источников в ноутбуке
- CLI команды нужны для интерактивной работы (REPL)

---

**Created:** 2026-02-09
**Status:** ✅ Active in [creative] and [business] personas
