# ⚡ YouTube Transcript API - Instant Captions

**Extract YouTube captions in milliseconds — no AI, no costs, no waiting!**

## Features

- ⚡ **Instant**: ~100ms (vs 30-60s with Whisper)
- 💰 **Free**: Uses YouTube's built-in captions
- 🎯 **Accurate**: Original creator captions/subtitles
- 🔧 **Easy**: Single Docker container
- 🌍 **Multilingual**: All available languages
- 🪶 **Lightweight**: 512MB RAM vs 4GB for Whisper

## Tech Stack

- **Backend**: FastAPI (Python 3.11)
- **Extraction**: youtube-transcript-api
- **Containerization**: Docker + docker-compose

## Quick Start

### 1. Setup

```bash
cd /root/.openclaw/workspace/services/youtube-transcriber

# Create .env
cat > .env << EOF
API_KEY=your-secret-api-key
EOF
```

### 2. Build & Run

```bash
# Use captions version
docker-compose -f docker-compose.captions.yml build
docker-compose -f docker-compose.captions.yml up -d

# Wait a second
sleep 2

# Test
curl -X GET http://localhost:8000/
```

### 3. Test the API

```bash
curl -X POST http://localhost:8000/transcribe \
  -H "Authorization: Bearer your-secret-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://youtu.be/dQw4w9WgXcQ",
    "format": "text"
  }'
```

## API Usage

### Supported URL Formats

All YouTube URL formats are automatically normalized:

- `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
- `https://youtu.be/dQw4w9WgXcQ`
- `https://youtube.com/shorts/dQw4w9WgXcQ`
- `https://www.youtube.com/embed/dQw4w9WgXcQ`
- `https://m.youtube.com/watch?v=dQw4w9WgXcQ`

### Output Formats

| Format | Description | Response Type |
|--------|-------------|---------------|
| `text` | Plain text (default) | JSON |
| `srt` | SubRip subtitles | Plain text |
| `vtt` | WebVTT subtitles | Plain text |
| `timestamps` | Text with [HH:MM:SS] | Plain text |

### Examples

#### 1. Plain Text (JSON)

```bash
curl -X POST http://localhost:8000/transcribe \
  -H "Authorization: Bearer your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://youtu.be/dQw4w9WgXcQ",
    "format": "text"
  }'
```

**Response:**
```json
{
  "text": "Never gonna give you up Never gonna let you down...",
  "language": "en",
  "duration": 212.0,
  "processing_time": 0.001,
  "video_id": "dQw4w9WgXcQ",
  "video_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
}
```

#### 2. SRT Subtitles

```bash
curl -X POST http://localhost:8000/transcribe \
  -H "Authorization: Bearer your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://youtu.be/dQw4w9WgXcQ",
    "format": "srt"
  }'
```

**Response:**
```srt
1
00:00:00.000 --> 00:00:02.500
Never gonna give you up

2
00:00:02.500 --> 00:00:05.000
Never gonna let you down
```

#### 3. Specific Language

```bash
curl -X POST http://localhost:8000/transcribe \
  -H "Authorization: Bearer your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://youtu.be/dQw4w9WgXcQ",
    "languages": ["en"],
    "format": "text"
  }'
```

#### 4. Multiple Languages (fallback)

```bash
# Try English, fallback to German
curl -X POST http://localhost:8000/transcribe \
  -H "Authorization: Bearer your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://youtu.be/dQw4w9WgXcQ",
    "languages": ["en", "de"],
    "format": "text"
  }'
```

### Check Available Languages

```bash
curl -X GET http://localhost:8000/languages/dQw4w9WgXcQ \
  -H "Authorization: Bearer your-api-key"
```

**Response:**
```json
{
  "video_id": "dQw4w9WgXcQ",
  "languages": {
    "manually_created": [
      {"language": "English", "language_code": "en", "is_generated": false}
    ],
    "generated": [
      {"language": "English", "language_code": "en", "is_generated": true}
    ],
    "translations": {...}
  }
}
```

## Comparison: Captions vs Whisper

| Feature | YouTube Captions | Whisper AI |
|---------|------------------|------------|
| **Speed** | ~100ms ⚡ | 30-60s |
| **CPU** | Minimal | Heavy |
| **RAM** | 256MB | 4GB |
| **Cost** | $0 | $0 (but resources) |
| **Accuracy** | Creator's captions | AI transcription |
| **Languages** | Available only | 99 languages |
| **Availability** | Not all videos | Any video |

## When to Use Each

**Use YouTube Captions when:**
- ✅ Video has captions (most popular videos)
- ✅ Need instant results
- ✅ Limited server resources
- ✅ Want original creator subtitles

**Use Whisper when:**
- ✅ No captions available
- ✅ Need transcription for obscure language
- ✅ Have powerful GPU server

## Production Deployment

### Requirements

Minimal VPS specs:
- CPU: 1 core
- RAM: 512MB
- Storage: 1GB
- Cost: ~$3-5/month (Hetzner, DigitalOcean)

### Nginx Reverse Proxy

```nginx
server {
    listen 80;
    server_name transcribe.yourdomain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Rate Limiting

Add to `requirements.txt`:
```txt
slowapi==0.1.9
```

Update `main.py`:
```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@app.post("/transcribe")
@limiter.limit("60/minute")  # 60 requests per minute
async def get_transcript(...):
    ...
```

## Monetization

Since this is so cheap to run:

1. **High-volume API**: $0.001 per request (1000x cheaper than competitors!)
2. **Freemium**: 100/day free, $5/month unlimited
3. **White-label**: Sell to other developers
4. **Browser extension**: Free tier + paid features

**Your costs**: $5/month VPS
**Potential revenue**: $100-1000/month

## Troubleshooting

### "Transcript not found"

Video doesn't have captions available. Solutions:
1. Check with `/languages/{video_id}` endpoint
2. Use Whisper fallback (hybrid approach)
3. Skip videos without captions

### Rate limiting

YouTube may rate limit if too many requests. Solutions:
1. Add caching (Redis)
2. Add delays between requests
3. Use multiple proxies

### Invalid URL

The API validates URLs automatically. Make sure:
- URL is complete
- Video exists
- Not private/restricted

## Advanced: Hybrid Approach

Combine both methods for maximum coverage:

```python
async def get_transcript_hybrid(url):
    try:
        # Try YouTube captions first (instant)
        return await extract_transcript(url)
    except:
        # Fallback to Whisper (slower but works)
        return await whisper_transcribe(url)
```

This gives you:
- ⚡ Instant results for 80% of videos
- 🎯 Coverage for 100% of videos

## Next Steps

- [ ] Add Redis caching
- [ ] Add rate limiting
- [ ] Create hybrid mode (captions + Whisper)
- [ ] Build frontend UI
- [ ] Add webhook support

## License

MIT License - Free to use!

---

**Made with ⚡ for instant, free transcript extraction**
