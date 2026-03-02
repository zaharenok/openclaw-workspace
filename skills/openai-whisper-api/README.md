# OpenAI Whisper API - Speech to Text

**Transcribe audio files using OpenAI's state-of-the-art Whisper API.**

## 🎤 What is Whisper API?

OpenAI Whisper is an automatic speech recognition (ASR) model trained on 680,000 hours of multilingual data. It supports 99 languages and achieves human-level accuracy.

## ⚡ Quick Start

### 1. Set API Key

```bash
export OPENAI_API_KEY="sk-..."
```

### 2. Transcribe Audio

```bash
# Basic transcription
./skills/openai-whisper-api/scripts/transcribe.sh voice.ogg

# To file
./skills/openai-whisper-api/scripts/transcribe.sh voice.ogg --out transcript.txt

# With language
./skills/openai-whisper-api/scripts/transcribe.sh voice.ogg --lang ru
```

## 💰 Pricing

**$0.006 per minute** — pay for what you use

Examples:
- 1 minute = $0.006
- 10 minutes = $0.06
- 1 hour = $0.36

## 🌍 Supported Languages

99 languages including:
- English, Spanish, Russian, French, German
- Chinese, Japanese, Korean, Arabic
- And 90+ more

## 📁 Supported Audio Formats

- MP3, MP4, MPEG, MPGA, M4A, WAV, WebM
- Max file size: 25 MB
- No duration limit

## 🎯 Use Cases

### 1. Telegram Voice Messages
```bash
# Transcribe voice message
transcribe.sh /tmp/voice_123.ogg --out /tmp/transcript_123.txt

# Send to chat
cat /tmp/transcript_123.txt
```

### 2. Meeting Notes
```bash
# Transcribe meeting recording
transcribe.sh meeting.mp3 --out notes.txt
```

### 3. Podcast Transcription
```bash
# Split into 10-min segments, transcribe each
transcribe.sh podcast_segment_01.mp3 --out segments/01.txt
```

### 4. Voice Memos
```bash
# Transcribe voice memos to text
transcribe.sh memo.m4a --out memo.txt
```

## 📊 Accuracy

**~95%+ accuracy** on clear speech

Factors affecting accuracy:
- ✅ Clear audio, single speaker → Best results
- ⚠️ Background noise → Reduced accuracy
- ⚠️ Multiple speakers → Confusion possible
- ⚠️ Strong accents → May need language hint

## 💡 Tips

**For best results:**
1. Specify language with `--lang` if known
2. Use quality audio (16kHz+ sample rate)
3. Split long files (>10 min) into segments
4. Remove background noise when possible

**Speed optimization:**
- Transcription is ~1-2x faster than real-time
- No need to split files for speed

## 🔧 Integration

### With Voice Processor Skill

The voice-processor skill automatically uses transcribe.sh:

```bash
# Automatic transcription
./skills/voice-processor/scripts/processor.sh process voice.ogg msg_123
```

### Manual Integration

```bash
# Capture transcript
TRANSCRIPT=$(transcribe.sh audio.ogg)

# Use in script
echo "You said: $TRANSCRIPT"
```

## 📋 Examples

### Example 1: Basic Transcription

```bash
$ transcribe.sh hello.ogg

Hello, how are you today?
```

### Example 2: Russian Language

```bash
$ transcribe.sh russian_voice.ogg --lang ru

Привет, как дела сегодня?
```

### Example 3: To File

```bash
$ transcribe.sh recording.mp3 --out transcript.txt
✓ Transcription saved to: transcript.txt

$ cat transcript.txt
This is the transcript text.
```

### Example 4: Language Auto-Detect

```bash
# No --lang flag, auto-detects
transcribe.sh mixed.ogg
# Automatically detects language from audio
```

## ⚙️ Options

| Option | Description |
|--------|-------------|
| `--out FILE` | Output to file instead of stdout |
| `--model MODEL` | Whisper model (default: whisper-1) |
| `--lang CODE` | Language code (en, ru, es, etc.) |
| `--api-key KEY` | OpenAI API key |
| `--help` | Show help message |

## 🐛 Troubleshooting

### "OPENAI_API_KEY not set"
```bash
# Set environment variable
export OPENAI_API_KEY="sk-..."
```

### "File not found"
```bash
# Use full path
transcribe.sh /full/path/to/audio.ogg
```

### "API request failed"
```bash
# Check API key is valid
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY"

# Check account has credits
```

### Poor transcription
- Use `--lang` for known language
- Improve audio quality
- Check for background noise
- Try shorter audio segments

## 📚 Documentation

- OpenAI Docs: https://platform.openai.com/docs/guides/speech-to-text
- API Reference: https://platform.openai.com/docs/api-reference/audio
- Model Card: https://github.com/openai/whisper

## 🔄 Related Skills

- **voice-processor** — Telegram voice message integration
- Uses this skill for automatic transcription

## 💰 Cost Calculator

```bash
# Calculate cost for audio file
duration_seconds=$(ffprobe -i audio.ogg -show_entries format=duration -v quiet -of csv="p=0")
duration_minutes=$(echo "$duration_seconds / 60" | bc)
cost=$(echo "$duration_minutes * 0.006" | bc)
echo "Duration: ${duration_minutes} min, Cost: \$${cost}"
```

## ✅ Requirements

- Bash shell
- curl
- python3 (for JSON parsing)
- OpenAI API key

## 📝 License

Uses OpenAI Whisper API (paid service).
This script is MIT-licensed.

---

**Last updated:** 2026-01-30
**Accuracy:** State-of-the-art speech recognition
**Speed:** 1-2x faster than real-time
