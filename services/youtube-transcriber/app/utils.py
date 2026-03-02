import os
import time
import re
from pathlib import Path
from typing import Optional

def cleanup_old_files(directory: str = "/tmp", max_age_hours: int = 1):
    """
    Remove old temporary files.
    """
    try:
        now = time.time()
        max_age_seconds = max_age_hours * 3600

        for file_path in Path(directory).glob("yt_transcribe_*"):
            if file_path.is_dir():
                age = now - file_path.stat().st_mtime
                if age > max_age_seconds:
                    # Remove directory and contents
                    for item in file_path.rglob("*"):
                        if item.is_file():
                            item.unlink()
                    file_path.rmdir()
                    print(f"Cleaned up old directory: {file_path}")
    except Exception as e:
        print(f"Cleanup error: {e}")

def format_timestamp(seconds: float) -> str:
    """
    Convert seconds to HH:MM:SS format.
    """
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    return f"{hours:02d}:{minutes:02d}:{secs:02d}"

def format_timestamp_srt(seconds: float) -> str:
    """
    Convert seconds to SRT timestamp format (HH:MM:SS,mmm).
    """
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    millis = int((seconds % 1) * 1000)
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"

def format_timestamp_vtt(seconds: float) -> str:
    """
    Convert seconds to WebVTT timestamp format (HH:MM:SS.mmm).
    """
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    millis = int((seconds % 1) * 1000)
    return f"{hours:02d}:{minutes:02d}:{secs:02d}.{millis:03d}"

def estimate_processing_time(audio_duration_seconds: float, model_size: str = "small") -> float:
    """
    Estimate processing time based on audio duration and model size.
    These are approximate real-world multipliers for faster-whisper on CPU.
    """
    multipliers = {
        "tiny": 0.05,   # ~5% of real-time
        "base": 0.1,    # ~10% of real-time
        "small": 0.15,  # ~15% of real-time
        "medium": 0.3,  # ~30% of real-time
        "large": 0.6    # ~60% of real-time
    }

    multiplier = multipliers.get(model_size, 0.15)
    return audio_duration_seconds * multiplier

def extract_video_id(url: str) -> Optional[str]:
    """
    Extract YouTube video ID from various URL formats.

    Supports:
    - youtube.com/watch?v=ID
    - youtu.be/ID
    - youtube.com/shorts/ID
    - youtube.com/embed/ID
    - m.youtube.com/watch?v=ID
    - youtube.com/v/ID
    - youtube.com/watch?v=ID&list=...
    - youtube.com/watch?v=ID&t=123
    """
    patterns = [
        r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/|youtube\.com\/v\/|m\.youtube\.com\/watch\?v=)([a-zA-Z0-9_-]{11})',
        r'youtube\.com\/shorts\/([a-zA-Z0-9_-]{11})',
    ]

    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)

    return None

def validate_youtube_url(url: str) -> bool:
    """
    Validate YouTube URL and extract video ID.
    Returns True if valid YouTube URL.
    """
    video_id = extract_video_id(url)
    return video_id is not None

def normalize_youtube_url(url: str) -> str:
    """
    Normalize any YouTube URL to standard format.
    Returns: https://www.youtube.com/watch?v=VIDEO_ID
    """
    video_id = extract_video_id(url)
    if video_id:
        return f"https://www.youtube.com/watch?v={video_id}"
    return url

def format_subtitles_srt(segments, video_id: str) -> str:
    """
    Format transcription segments as SRT subtitles.
    """
    srt_content = []
    for i, segment in enumerate(segments, 1):
        start_time = format_timestamp_srt(segment.start)
        end_time = format_timestamp_srt(segment.end)
        text = segment.text.strip()

        srt_content.append(f"{i}")
        srt_content.append(f"{start_time} --> {end_time}")
        srt_content.append(text)
        srt_content.append("")  # Empty line between entries

    return "\n".join(srt_content)

def format_subtitles_vtt(segments, video_id: str) -> str:
    """
    Format transcription segments as WebVTT subtitles.
    """
    vtt_content = ["WEBVTT", ""]
    for i, segment in enumerate(segments):
        start_time = format_timestamp_vtt(segment.start)
        end_time = format_timestamp_vtt(segment.end)
        text = segment.text.strip()

        vtt_content.append(f"{i + 1}")
        vtt_content.append(f"{start_time} --> {end_time}")
        vtt_content.append(text)
        vtt_content.append("")

    return "\n".join(vtt_content)

def format_subtitle_timestamps(segments) -> str:
    """
    Format transcription with timestamps as text.
    Format: [HH:MM:SS] Text here
    """
    lines = []
    for segment in segments:
        timestamp = format_timestamp(segment.start)
        text = segment.text.strip()
        lines.append(f"[{timestamp}] {text}")

    return "\n".join(lines)

def format_plain_text(segments) -> str:
    """
    Format transcription as plain text without timestamps.
    """
    return " ".join([segment.text.strip() for segment in segments])

def get_video_info_from_api(video_id: str) -> dict:
    """
    Get video metadata from YouTube (no API key needed).
    Uses yt-dlp to extract video info.
    """
    import subprocess
    import json

    cmd = [
        "yt-dlp",
        "--dump-json",
        "--no-playlist",
        f"https://www.youtube.com/watch?v={video_id}"
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            data = json.loads(result.stdout)
            return {
                "title": data.get("title", "Unknown"),
                "duration": data.get("duration", 0),
                "uploader": data.get("uploader", "Unknown"),
                "upload_date": data.get("upload_date", "Unknown"),
                "view_count": data.get("view_count", 0),
                "thumbnail": data.get("thumbnail", "")
            }
    except Exception as e:
        print(f"Error getting video info: {e}")

    return {}
