# Команды OpenClaw

Удобные команды для повседневной работы в OpenClaw.

## 🎬 YouTube Транскрипция

```bash
# Быстрая транскрипция (русский по умолчанию)
yt "https://youtube.com/watch?v=VIDEO_ID"

# С указанием языка
yt "URL" "English"

# Полное название команды
youtube-transcribe "URL" "Russian"

# Справка
yt --help
```

**Сохраняется в:** `workspace/knowledge/youtube/`

---

## 📁 Другие команды

### GitHub Backup
```bash
backup-to-github.sh
```

### Secrets Check
```bash
check-secrets.sh
```

### Chunk Message (Telegram)
```bash
chunk-message "очень длинный текст"
```

### Smart OpenCode
```bash
smart-opencode ./project "задача"
```

### Create GitHub Repo
```bash
create-github-repo.sh "repo-name"
```

---

**Все команды в:** `workspace/bin/`

**Добавить в PATH** (уже добавлено в `~/.bashrc`):
```bash
export PATH="$HOME/.openclaw/workspace/bin:$PATH"
```
