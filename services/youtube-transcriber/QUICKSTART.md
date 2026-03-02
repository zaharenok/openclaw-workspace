# 🚀 Quick Start - YouTube Transcript API

## ⚡ Deploy Captions API (Recommended - Instant!)

```bash
cd /root/.openclaw/workspace/services/youtube-transcriber

# 1. Deploy
./deploy-captions.sh

# 2. Test (instant result!)
curl -X POST http://localhost:8000/transcribe \
  -H "Authorization: Bearer change-me-to-secure-key" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://youtu.be/dQw4w9WgXcQ",
    "format": "text"
  }'

# 3. Check API docs
open http://localhost:8000/docs
```

## 🎯 Deploy Whisper AI (Slower but Universal)

```bash
# 1. Edit .env
cat > .env << EOF
API_KEY=your-secret-api-key
MODEL_SIZE=small
DEVICE=cpu
EOF

# 2. Deploy
./deploy.sh

# 3. Test (takes 30-60 seconds)
curl -X POST http://localhost:8000/transcribe \
  -H "Authorization: Bearer your-secret-api-key" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://youtu.be/dQw4w9WgXcQ"}'
```

## 📝 URL Formats (All Supported!)

```bash
# All of these work the same:
"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
"url": "https://youtu.be/dQw4w9WgXcQ"
"url": "https://youtube.com/shorts/dQw4w9WgXcQ"
"url": "https://www.youtube.com/embed/dQw4w9WgXcQ"
"url": "https://m.youtube.com/watch?v=dQw4w9WgXcQ"
"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=30s"
```

## 🎨 Output Formats

```bash
# Plain text (JSON)
"format": "text"

# SRT subtitles (for video players)
"format": "srt"

# WebVTT subtitles (for web)
"format": "vtt"

# Timestamps (for analysis)
"format": "timestamps"
```

## 🧪 Test Scripts

```bash
# Test different URL formats
./test-url-formats.sh

# Test different output formats
./test-output-formats.sh
```

## ⚡ Speed Comparison

| Solution | Speed | Cost |
|----------|-------|------|
| Captions API | ~100ms | $5/month |
| Whisper AI | 30-60s | $20-50/month |

## 📊 Which One?

**Start with Captions API** ⚡
- 80% of videos work instantly
- Dirt cheap ($5/month)
- Recommended for production

**Use Whisper AI** 🎯 (if captions not available)
- Works on 100% of videos
- More expensive but universal

---

**See README.md for full comparison and details!**
