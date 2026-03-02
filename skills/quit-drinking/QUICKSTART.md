# 🚫 Sobriety Coach - Quick Start

## Активация

```
[quit-drinking] [ваш вопрос или задача]
```

## Примеры использования

**Начать journey:**
```
[quit-drinking] Хочу бросить пить. День 1.
```

**Получить мотивацию:**
```
[quit-drinking] motivate
[quit-drinking] напомни почему я это делаю
```

**План для сложной ситуации:**
```
[quit-drinking] plan для вечеринки в субботу
[quit-drinking] что делать если сильно захочется выпить
```

**После срыва:**
```
[quit-drinking] Я сорвался вчера
[quit-drinking] reset day 1
```

**Отследить прогресс:**
```
[quit-drinking] track
[quit-drinking] я на 15 дне
```

## Скрипты

```bash
# Начать трекинг
./skills/quit-drinking/scripts/tracker.sh start

# Показать статус
./skills/quit-drinking/scripts/tracker.sh status

# Записать craving
./skills/quit-drinking/scripts/craving-log.sh "стресс от работы"

# Показать последние cravings
./skills/quit-drinking/scripts/craving-log.sh list

# Анализ триггеров
./skills/quit-drinking/scripts/craving-log.sh analyze
```

## Полная документация

См. `README.md` для полной документации.

---

*One day at a time. 💪*
