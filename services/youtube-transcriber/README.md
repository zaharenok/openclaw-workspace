# 🎬 YouTube Transcriber - Two Solutions

**Choose your approach:**
- ⚡ **Captions API**: Instant extraction (100ms)
- 🎯 **Whisper AI**: Full transcription (30-60s)

## Quick Comparison

| Feature | Captions API | Whisper AI |
|---------|--------------|------------|
| **Speed** | ~100ms ⚡ | 30-60s |
| **CPU/RAM** | Minimal (256MB) | Heavy (4GB) |
| **Cost** | $0 | $0 (VPS needed) |
| **Accuracy** | Creator's captions | AI transcription |
| **Coverage** | ~80% of videos | 100% of videos |
| **Languages** | Available only | 99 languages |

## Solution 1: Captions API ⚡ (Recommended)

**Best for**: Most videos, instant results, low cost

### Quick Start

```bash
cd /root/.openclaw/workspace/services/youtube-transcriber

# Deploy
./deploy-captions.sh

# Test
curl -X POST http://localhost:8000/transcribe \
  -H "Authorization: Bearer change-me-to-secure-key" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://youtu.be/dQw4w9WgXcQ"}'
```

### Files

- `Dockerfile.captions` - Lightweight container
- `docker-compose.captions.yml` - Minimal resources
- `app/extractor.py` - YouTube transcript extraction
- `README.captions.md` - Full documentation

### Pros

- ⚡ Instant (milliseconds)
- 💰 Dirt cheap ($5/month VPS)
- 🪶 Lightweight (512MB RAM)
- ✅ Original creator subtitles

### Cons

- ❌ Not all videos have captions
- ❌ Limited to available languages

---

## Solution 2: Whisper AI 🎯 (Fallback)

**Best for**: Videos without captions, obscure languages, maximum coverage

### Quick Start

```bash
cd /root/.openclaw/workspace/services/youtube-transcriber

# Deploy
./deploy.sh

# Test
curl -X POST http://localhost:8000/transcribe \
  -H "Authorization: Bearer your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://youtu.be/dQw4w9WgXcQ"}'
```

### Files

- `Dockerfile` - Full AI container
- `docker-compose.yml` - GPU support
- `app/transcriber.py` - Whisper transcription
- `README.whisper.md` - Full documentation

### Pros

- ✅ Works on ANY video
- 🌍 99 languages
- 🎯 High accuracy
- 🔄 No dependencies on captions

### Cons

- 🐢 Slow (30-60 seconds)
- 💸 Expensive VPS ($20-50/month)
- 🏋️ Heavy (4GB RAM, GPU recommended)

---

## Hybrid Approach 🔄 (Best of Both!)

**Strategy**: Try captions first, fallback to Whisper

```python
async def get_transcript_hybrid(url):
    try:
        # Try instant captions (100ms)
        return await extract_captions(url)
    except:
        # Fallback to Whisper (30s)
        return await whisper_transcribe(url)
```

**Results:**
- ⚡ 80% of videos: Instant (100ms)
- 🎯 100% coverage: Always works

---

## API Usage (Same for Both!)

### Supported URL Formats

All formats are automatically normalized:
- `youtube.com/watch?v=ID`
- `youtu.be/ID`
- `youtube.com/shorts/ID`
- `youtube.com/embed/ID`
- `m.youtube.com/watch?v=ID`

### Output Formats

| Format | Description | Type |
|--------|-------------|------|
| `text` | Plain text | JSON |
| `srt` | SubRip subtitles | Plain text |
| `vtt` | WebVTT subtitles | Plain text |
| `timestamps` | Text with [HH:MM:SS] | Plain text |

### Example Request

```bash
curl -X POST http://localhost:8000/transcribe \
  -H "Authorization: Bearer your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://youtu.be/dQw4w9WgXcQ",
    "format": "srt"
  }'
```

### Example Response

```json
{
  "text": "Never gonna give you up...",
  "language": "en",
  "duration": 212.0,
  "processing_time": 0.001,
  "video_id": "dQw4w9WgXcQ",
  "video_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
}
```

---

## Which One Should You Use?

### Start with Captions API if:
- ✅ You want to minimize costs
- ✅ Most of your videos have captions
- ✅ Speed is important
- ✅ Running on small VPS

### Use Whisper AI if:
- ✅ You need 100% coverage
- ✅ Working with obscure languages
- ✅ Videos often lack captions
- ✅ Have powerful GPU server

### Use Hybrid if:
- ✅ You want maximum speed + coverage
- ✅ Budget allows both services
- ✅ Want seamless fallback

---

## Deployment

### Captions API (Recommended)

```bash
# 1. Setup
./deploy-captions.sh

# 2. Test
curl http://localhost:8000/

# 3. Check logs
docker-compose -f docker-compose.captions.yml logs -f
```

**Requirements:**
- CPU: 1 core
- RAM: 512MB
- Cost: $3-5/month

### Whisper AI

```bash
# 1. Setup
./deploy.sh

# 2. Test
curl http://localhost:8000/

# 3. Check logs
docker-compose logs -f
```

**Requirements:**
- CPU: 2+ cores
- RAM: 4GB (CPU) or 8GB (GPU)
- Cost: $20-50/month

---

## Cost Comparison

| Solution | VPS Cost | Coverage | Speed |
|----------|----------|----------|-------|
| Captions API | $5/month | 80% | ⚡ 100ms |
| Whisper AI | $20-50/month | 100% | 🐢 30-60s |
| Hybrid | $30-60/month | 100% | ⚡/🐢 |

---

## Monetization Ideas

Since Captions API is so cheap:

1. **High-volume API**: $0.001 per request
   - Your cost: $0.0001 per request
   - Profit margin: 1000% 🎉

2. **Freemium service**:
   - Free: 100 requests/day
   - Pro: $5/month unlimited
   - Your cost: $5/month

3. **White-label solution**:
   - Sell to other developers
   - Charge $50-100/month

4. **Browser extension**:
   - Free tier (ads)
   - Premium $2.99/month
   - Your cost: negligible

---

## Next Steps

1. **Deploy Captions API** (start here)
   ```bash
   ./deploy-captions.sh
   ```

2. **Test with real videos**
   ```bash
   ./test-url-formats.sh
   ./test-output-formats.sh
   ```

3. **Add rate limiting** (production)
4. **Setup domain + SSL**
5. **Start monetizing!** 💰

---

## Documentation

- **README.captions.md** - Captions API details
- **README.whisper.md** - Whisper AI details (old README.md)
- **QUICKSTART.md** - Quick start guide

---

## License

MIT License - Free to use!

---

**Questions? Check the individual README files for each solution!** 📚
