from fastapi import FastAPI, HTTPException, BackgroundTasks, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.responses import PlainTextResponse
from pydantic import BaseModel
from typing import Optional, Literal
from .extractor import extract_transcript, TranscriptExtractor
from .utils import extract_video_id, validate_youtube_url

app = FastAPI(
    title="YouTube Transcript API",
    description="Extract YouTube captions instantly - no AI needed!",
    version="2.0.0"
)

security = HTTPBearer()

# Verify API key
async def verify_api_key(credentials: HTTPAuthorizationCredentials = Depends(security)):
    import os
    api_key = os.getenv("API_KEY", "your-secret-api-key")
    if credentials.credentials != api_key:
        raise HTTPException(status_code=403, detail="Invalid API key")
    return credentials.credentials

class TranscriptRequest(BaseModel):
    url: str  # Accept any string URL format
    languages: Optional[list[str]] = None  # e.g., ["en", "ru"]
    format: Optional[Literal["text", "srt", "vtt", "timestamps"]] = "text"

class HealthResponse(BaseModel):
    status: str
    version: str
    method: str

@app.get("/", response_model=HealthResponse)
async def root():
    return HealthResponse(
        status="healthy",
        version="2.0.0",
        method="youtube-transcript-api"
    )

@app.get("/health")
async def health():
    return {"status": "ok", "method": "youtube-transcript-api"}

@app.post("/transcribe")
async def get_transcript(
    request: TranscriptRequest,
    api_key: str = Depends(verify_api_key)
):
    """
    Extract YouTube captions instantly.

    URL formats supported:
    - youtube.com/watch?v=ID
    - youtu.be/ID
    - youtube.com/shorts/ID
    - youtube.com/embed/ID
    - m.youtube.com/watch?v=ID

    Output formats:
    - text: Plain text (default)
    - srt: SubRip subtitles with timestamps
    - vtt: WebVTT subtitles
    - timestamps: Text with [HH:MM:SS] timestamps

    Language options:
    - null: Auto-detect
    - ["en"]: English only
    - ["en", "ru"]: Try English, fallback to Russian
    """
    # Validate URL
    if not validate_youtube_url(request.url):
        raise HTTPException(status_code=400, detail="Invalid YouTube URL")

    video_id = extract_video_id(request.url)

    try:
        result = await extract_transcript(
            request.url,
            languages=request.languages,
            format=request.format
        )

        # Return plain text for subtitle formats
        if request.format in ["srt", "vtt", "timestamps"]:
            media_type = "text/vtt" if request.format == "vtt" else "text/plain"
            return PlainTextResponse(content=result["text"], media_type=media_type)

        # Return JSON for text format
        return {
            "text": result["text"],
            "language": result["language"],
            "duration": result["duration"],
            "processing_time": result["processing_time"],
            "video_id": result["video_id"],
            "video_url": result["video_url"]
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/languages/{video_id}")
async def get_available_languages(
    video_id: str,
    api_key: str = Depends(verify_api_key)
):
    """
    Get all available transcript languages for a video.
    """
    try:
        languages = TranscriptExtractor.get_available_transcripts(video_id)
        return {
            "video_id": video_id,
            "languages": languages
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
