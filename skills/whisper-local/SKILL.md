# Whisper Local - Local Speech-to-Text

## Overview

Transcribes audio files locally using OpenAI's Whisper model — no API key needed, runs entirely on your machine.

## Prerequisites

- **Python 3.8+** with `uv` package manager
- **Audio formats:** mp3, mp4, mpeg, mpga, m4a, wav, webm, ogg, flac
- **Disk space:** ~1-3GB for model downloads (cached in `~/.cache/whisper`)

## Installation

### Option 1: Using UV (Recommended)

```bash
# Install Whisper CLI
uv tool install whisper-cli

# Or install from PyPI
pip install whisper-cli
```

### Option 2: Using pipx

```bash
pipx install whisper-cli
```

### Option 3: Direct pip install

```bash
pip install -U openai-whisper
```

## Usage

### Basic Usage

```bash
# Transcribe audio to text
whisper /path/audio.mp3 --model medium --output_format txt --output_dir .

# Translate to English
whisper /path/audio.m4a --task translate --output_format srt

# Fast transcription (smaller model)
whisper /path/audio.mp3 --model small --output_format txt
```

### Model Sizes

| Model | Size | VRAM | Speed | Accuracy |
|-------|------|------|-------|----------|
| tiny  | 39M  | ~1GB | ⚡⚡⚡ | Fastest |
| base  | 74M  | ~1GB | ⚡⚡ | Quick |
| small | 244M | ~2GB | ⚡ | Balanced |
| medium| 769M | ~5GB | - | Accurate |
| large | 1550M| ~10GB | 🐌 | Best |

### Output Formats

- `txt` — Plain text transcript
- `srt` — SubRip subtitles
- `vtt` — WebVTT subtitles
- `json` — JSON with timestamps

## Script Usage

The `transcribe.sh` script simplifies common tasks:

```bash
# Transcribe to stdout
./skills/whisper-local/scripts/transcribe.sh audio.mp3

# Transcribe to file
./skills/whisper-local/scripts/transcribe.sh audio.mp3 --out transcript.txt

# With specific model
./skills/whisper-local/scripts/transcribe.sh audio.mp3 --model medium

# With language hint (auto-detect if empty)
./skills/whisper-local/scripts/transcribe.sh audio.mp3 --lang ru

# Translate to English
./skills/whisper-local/scripts/transcribe.sh audio.mp3 --translate
```

## Notes

- **First run:** Models download automatically to `~/.cache/whisper`
- **Default model:** `turbo` on modern installs
- **Language:** Auto-detects if not specified (supports 99 languages)
- **GPU:** Uses GPU if available (faster transcription)
- **CPU fallback:** Works on CPU if no GPU (slower but functional)

## Examples

### Transcribe Voice Memo

```bash
whisper voice-memo.m4a --model small --output_format txt
```

### Create Subtitles

```bash
whisper video.mp4 --model medium --output_format srt
```

### Translate to English

```bash
whisper spanish-audio.mp3 --task translate --output_format txt
```

### Batch Process

```bash
for file in *.mp3; do
  whisper "$file" --model small --output_format txt
done
```

## Troubleshooting

### Command not found

```bash
# Check if whisper is installed
which whisper

# If using uv
export PATH="$HOME/.local/bin:$PATH"
```

### Model download fails

```bash
# Manually download models to ~/.cache/whisper
# Or set custom cache directory:
export XDG_CACHE_HOME=/custom/path
```

### Out of memory

```bash
# Use smaller model
whisper audio.mp3 --model tiny
```

## Performance Tips

- **Use `tiny` or `base`** for quick drafts
- **Use `medium`** for balance of speed/accuracy
- **Use `large`** for final production transcripts
- **GPU acceleration** makes it 5-10x faster
- **Batch processing** is more efficient than individual files

## Comparison: Whisper API vs Local

| Feature | Local | API |
|---------|-------|-----|
| Cost | Free | $0.006/minute |
| Privacy | 100% local | Sent to OpenAI |
| Speed | Depends on hardware | Fast (cloud) |
| Offline | Yes | No |
| Setup | One-time install | API key required |

---

**Emoji:** 🎙️  
**Homepage:** https://openai.com/research/whisper  
**Installation:** `uv tool install whisper-cli` or `pip install openai-whisper`
