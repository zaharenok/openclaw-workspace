# Whisper Local Skill

🎙️ **Local speech-to-text transcription using OpenAI's Whisper model**

## Quick Start

```bash
# Transcribe audio file
./skills/whisper-local/scripts/transcribe.sh audio.mp3

# With specific model
./skills/whisper-local/scripts/transcribe.sh audio.mp3 --model small

# Create subtitles
./skills/whisper-local/scripts/transcribe.sh video.mp4 --format srt
```

## Installation

Whisper is already installed via `uv tool install whisper-cli`.

If you need to reinstall:

```bash
# Using UV (recommended)
uv tool install whisper-cli

# Or using pip
pip install openai-whisper
```

## Features

- ✅ **100% local** — No API key needed, complete privacy
- ✅ **99 languages** — Auto-detect or specify language
- ✅ **Multiple formats** — txt, srt, vtt, json
- ✅ **Flexible models** — From tiny (fast) to large (accurate)
- ✅ **Translation** — Translate to English automatically

## Model Sizes

| Model | Size | Speed | Accuracy | Use Case |
|-------|------|-------|----------|----------|
| tiny  | 39M  | ⚡⚡⚡ | Quick drafts |
| base  | 74M  | ⚡⚡  | Notes, memos |
| small | 244M | ⚡   | General use |
| medium| 769M | -    | High quality |
| large | 1550M| 🐌  | Best accuracy |

## Examples

### Transcribe Voice Memo

```bash
transcribe.sh voice-memo.m4a --model small
```

### Create Subtitles for Video

```bash
transcribe.sh video.mp4 --format srt --model medium
```

### Translate Foreign Audio

```bash
transcribe.sh spanish-podcast.mp3 --translate --model medium
```

### Batch Processing

```bash
for file in ~/Downloads/*.mp3; do
  ./skills/whisper-local/scripts/transcribe.sh "$file" --model tiny
done
```

## Script Options

```bash
transcribe.sh <audio_file> [options]

Options:
  --model MODEL       Model size: tiny, base, small, medium, large
  --format FORMAT     Output: txt, srt, vtt, json
  --lang LANG         Language code (en, ru, es, etc.)
  --translate         Translate to English
  --out FILE          Custom output path
  --output-dir DIR    Output directory
```

## Comparison: API vs Local

| Feature | Local | API |
|---------|-------|-----|
| **Cost** | Free | $0.006/min |
| **Privacy** | 100% local | Sent to OpenAI |
| **Speed** | Depends on hardware | Fast (cloud) |
| **Offline** | Yes ✅ | No ❌ |
| **Setup** | One-time install | API key |

## Full Documentation

See `SKILL.md` for complete documentation.

## Requirements

- Python 3.8+
- `uv` package manager
- 1-3GB disk space for models

## Troubleshooting

**Whisper command not found?**
```bash
export PATH="$HOME/.local/bin:$PATH"
```

**Out of memory?**
```bash
# Use smaller model
transcribe.sh audio.mp3 --model tiny
```

**Models not downloading?**
```bash
# Models cache in ~/.cache/whisper
# Check disk space: df -h
```

---

**Skill Directory:** `skills/whisper-local/`
**Binary:** `~/.local/bin/whisper`
**Models Cache:** `~/.cache/whisper/`
