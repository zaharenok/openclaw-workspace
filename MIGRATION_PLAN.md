# 📋 План Реорганизации Репозиториев

**Цель:** Упростить управление проектами через единую структуру ~/repos/

---

## 🔍 Текущая Проблема

### Сейчас:
```
/root/.openclaw/workspace/
├── .git/                    ← openclaw-workspace.git (НЕ СУЩЕСТВУЕТ!)
├── deploy/poker-strategy/
│   └── .git/               ← Отдельный репозиторий (без remote)
├── knowledge/poker/
│   └── .git/               ← poker-strategy.git (работает!)
└── whatsapp-dietitian/
    └── .git/               ← Неизвестный remote
```

**Проблемы:**
- ❌ Вложенные git репозитории
- ❌ "nested repository" warnings
- ❌ Сложно бэкапить (конфликты)
- ❌ Неясно какой репозиторий главный

---

## ✅ Предлагаемое Решение

### Структура ~/repos/:

```
~/repos/
├── poker-strategy/          ← Покерные стратегии + API
│   └── .git/            ← poker-strategy.git
│
├── poker-strategy-deploy/   ← Deployment package для Render.com
│   └── .git/            ← poker-strategy-deploy.git
│
├── whatsapp-dietitian/       ← WhatsApp бот
│   └── .git/            ← whatsapp-dietitian.git
│
├── ai-video-transcriber/     ← AI видео транскрипция
│   └── .git/            ← ai-video-transcriber.git
│
├── youtube-tools/            ← YouTube скрейперы
│   ├── youtube-scraper/.git/
│   └── youtube-transcriber/.git/
│
└── openclaw-workspace/      ← OpenClaw конфигурация
    └── .git/            ← openclaw-workspace.git
```

---

## 🚀 План Миграции

### Шаг 1: Создать ~/repos/

```bash
mkdir -p ~/repos
cd ~/repos
```

### Шаг 2: Переместить проекты

```bash
# 1. Poker Strategy (knowledge/poker)
mv /root/.openclaw/workspace/knowledge/poker ~/repos/poker-strategy

# 2. Poker Strategy Deploy (deploy/poker-strategy)
mv /root/.openclaw/workspace/deploy/poker-strategy ~/repos/poker-strategy-deploy

# 3. WhatsApp Dietitian
mv /root/.openclaw/workspace/whatsapp-dietitian ~/repos/whatsapp-dietitian

# 4. AI Video Transcriber (если нужно)
mkdir -p ~/repos/ai-video-transcriber
git clone https://github.com/zaharenok/ai-video-transcriber.git ~/repos/ai-video-transcriber
```

### Шаг 3: Настроить remotes

```bash
cd ~/repos/poker-strategy
# Уже настроен на poker-strategy.git ✅

cd ~/repos/poker-strategy-deploy
git remote add origin https://github.com/zaharenok/poker-strategy-deploy.git
git push -u origin main

cd ~/repos/whatsapp-dietitian
git remote add origin https://github.com/zaharenok/whatsapp-dietitian.git
git push -u origin main
```

### Шаг 4: Обновить .gitignore

```bash
# /root/.openclaw/workspace/.gitignore

# Отдельные репозитории (теперь в ~/repos)
repos/
# Но не исключать symbolic links если будем их использовать
```

---

## 📊 Преимущества Новой Структуры

### ✅ **До:** (Было)
- ❌ Вложенные репозитории
- ❌ "nested repository" warnings
- ❌ Конфликты при бэкапе
- ❌ Сложная структура

### ✅ **После:** (Станет)
- ✅ Каждый проект независимо
- ✅ Прямая структура ~/repos/
- ✅ Легко бэкапить каждый проект
- ✅ Чистые коммиты
- ✅ Понятная иерархия

---

## 🎯 Дополнительные Улучшения

### Вариант A: Symbolic Links (опционально)

```bash
# В workspace создать ссылки на ~/repos
cd /root/.openclaw/workspace

ln -s ~/repos/poker-strategy knowledge/poker
ln -s ~/repos/poker-strategy-deploy deploy/poker-strategy
ln -s ~/repos/whatsapp-dietitian whatsapp-dietitian
```

**Плюсы:**
- ✅ Быстрый доступ из workspace
- ✅ Все проекты в ~/repos/ (для бэкапа)

**Минусы:**
- ❌ Git может не следить за символическими ссылками

### Вариант B: Workspace без .git (рекомендую)

```bash
# Убрать .git из workspace
rm -rf /root/.openclaw/workspace/.git

# Workspace становится просто рабочей директорией
# Все репозитории в ~/repos/
```

**Плюсы:**
- ✅ Максимальная простота
- ✅ Никаких конфликтов
- ✅ Workspace для временных файлов

---

## 📝 Итоговое Предложение

### 🎯 **Основная идея:**

```
~/repos/              ← Все проекты (каждый со своим .git)
  ├── poker-strategy/
  ├── poker-strategy-deploy/
  ├── whatsapp-dietitian/
  ├── ai-video-transcriber/
  └── openclaw-workspace/

/root/.openclaw/workspace/  ← Рабочая директория (без .git)
  ├── bin/               ← Скрипты
  ├── skills/            ← OpenClaw skills
  ├── memory/             ← Логи памяти
  └── ...                ← Временные файлы
```

### ✅ **Результат:**
1. Каждый проект = отдельный репозиторий
2. Простая структура ~/repos/
3. Никаких nested репозиториев
4. Легкий бэкап и управление

---

**Дата:** 2026-02-11
**Автор:** Oleg (@zaharenok)
**Статус:** Предложение к обсуждению
