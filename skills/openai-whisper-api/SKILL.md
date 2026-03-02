# OpenAI Whisper API - Technical Guide

## Overview

Transcribes audio files using OpenAI's Whisper API — state-of-the-art speech recognition model supporting 99 languages.

## Prerequisites

- **OpenAI API key:** Set `OPENAI_API_KEY` environment variable
- **Audio formats:** mp3, mp4, mpeg, mpga, m4a, wav, webm
- **Max file size:** 25 MB
- **Max duration:** No limit (but costs scale with duration)

## Setup

### 1. Get API Key

```bash
# Set environment variable
export OPENAI_API_KEY="sk-..."

# Or add to ~/.bashrc
echo 'export OPENAI_API_KEY="sk-..."' >> ~/.bashrc
```

### 2. Test Transcription

```bash
./skills/openai-whisper-api/scripts/transcribe.sh voice.ogg
```

## Usage

### Basic Usage

```bash
# Transcribe to stdout
transcribe.sh audio.mp3

# Transcribe to file
transcribe.sh audio.mp3 --out transcript.txt

# With language hint (auto-detect if empty)
transcribe.sh audio.mp3 --lang ru

# With API key override
transcribe.sh audio.mp3 --api-key sk-...
```

### Options

- `--out FILE` — Output transcript to file
- `--model MODEL` — Whisper model (default: whisper-1)
- `--lang CODE` — Language code (en, es, ru, fr, de, etc.)
- `--api-key KEY` — OpenAI API key
- `--help` — Show help message

## Audio Requirements

### Supported Formats
- MP3, MP4, MPEG, MPGA, M4A, WAV, WebM

### Best Practices
- **Sample rate:** 16 kHz+ for speech
- **Bitrate:** 64+ kbps for voice
- **Duration:** Any length (charged per second)
- **Size:** < 25 MB per file

### Language Support

99 languages including:
- English (en)
- Spanish (es)
- Russian (ru)
- French (fr)
- German (de)
- Chinese (zh)
- Japanese (ja)
- And 90+ more

Use `--lang` for better accuracy with known language.

## Output

### Text Format (default)
```
Привет, как дела? Это пример транскрипции.
```

### File Output
```bash
$ transcribe.sh voice.ogg --out transcript.txt
✓ Transcription saved to: transcript.txt

$ cat transcript.txt
Привет, как дела?
```

## Pricing (2025)

Whisper API costs:
- **$0.006 per minute** ($0.006 / 60 seconds = $0.0001 per second)
- Charged per second of audio
- No minimum duration

Example costs:
- 1 minute = $0.006
- 10 minutes = $0.06
- 1 hour = $0.36

## Integration Examples

### With Voice Processor

```bash
# In voice-processor/scripts/processor.sh
WHISPER_SCRIPT="/home/node/.openclaw/workspace/skills/openai-whisper-api/scripts/transcribe.sh"

# Transcribe
transcript=$("$WHISPER_SCRIPT" "$audio_file" --lang "$LANGUAGE")
```

### With Telegram

```bash
# When voice message received
transcribe.sh /tmp/voice_123.ogg --out /tmp/transcript_123.txt

# Send to chat
cat /tmp/transcript_123.txt | telegram-send --format markdown
```

### Batch Processing

```bash
# Transcribe all files in directory
for file in /audio/*.ogg; do
  base=$(basename "$file" .ogg)
  transcribe.sh "$file" --out "transcripts/$base.txt"
done
```

## Performance

### Speed
- **~1-2 seconds** per minute of audio
- Faster than real-time for most files

### Accuracy
- **~95%+ accuracy** on clear speech
- Lower with:
  - Background noise
  - Multiple speakers
  - Accents/dialects
  - Poor audio quality

### Tips for Better Accuracy
1. **Clean audio** — Remove noise when possible
2. **Single speaker** — One person at a time
3. **Good mic** — Quality input matters
4. **Specify language** — Use `--lang` if known
5. **Short segments** — < 10 minutes is optimal

## Troubleshooting

### Error: "OPENAI_API_KEY not set"
```bash
export OPENAI_API_KEY="sk-..."
# Or
transcribe.sh file.ogg --api-key sk-...
```

### Error: "File not found"
```bash
# Check path
ls -la /path/to/audio.ogg

# Use absolute path
transcribe.sh /full/path/to/audio.ogg
```

### Error: "API request failed"
```bash
# Check API key is valid
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY"

# Check account has credits
# Visit: https://platform.openai.com/account/usage
```

### Poor transcription quality
- Specify language with `--lang`
- Improve audio quality
- Split long files into segments
- Check for background noise

## Advanced Usage

### JSON Output Format

Modify script to add:
```bash
CURL_CMD+=(-F "response_format=verbose_json")
```

Returns JSON with:
- `text` — Transcript
- `segments` — Time-coded segments
- `language` — Detected language

### Timestamps

Request timestamps in response:
```python
# Python example
response = openai.audio.transcriptions.create(
  model="whisper-1",
  file=file,
  response_format="srt"  # or "vtt"
)
```

Returns:
```
1
00:00:00 --> 00:00:02
Привет, как дела?

2
00:00:02 --> 00:00:05
Это пример транскрипции.
```

## Alternatives

### Other Transcription Services
- **Google Cloud Speech-to-Text** — $0.006/minute (similar)
- **AWS Transcribe** — $0.024/minute (4x more)
- **Azure Speech** — $1/hour (expensive)
- **Whisper Local** — Free (needs GPU, slower)

### When to Use Each
- **Whisper API** — Best accuracy, simple, pay-as-you-go
- **Whisper Local** — Free, privacy, needs hardware
- **Google/AWS** — Regional compliance, existing cloud

## Scripts

### `transcribe.sh`
Main transcription script.

**Location:** `skills/openai-whisper-api/scripts/transcribe.sh`

**Usage:**
```bash
transcribe.sh [OPTIONS] <audio_file>
```

**Dependencies:** bash, curl, python3 (for JSON parsing)

## File Structure

```
skills/openai-whisper-api/
├── SKILL.md           # This file
└── scripts/
    └── transcribe.sh  # Main script
```

## Related Skills

- **voice-processor** — Telegram voice integration
- Uses transcribe.sh for Telegram voice messages

## Support

- OpenAI Docs: https://platform.openai.com/docs/guides/speech-to-text
- API Reference: https://platform.openai.com/docs/api-reference/audio
- Pricing: https://openai.com/pricing

---

**Last updated:** 2026-01-30
**Model:** whisper-1 (large-v2 equivalent)
**Accuracy:** State-of-the-art for speech recognition
