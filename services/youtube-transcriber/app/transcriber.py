import asyncio
import os
import time
import tempfile
import subprocess
from pathlib import Path
from faster_whisper import WhisperModel

# Model settings
DEFAULT_MODEL_SIZE = os.getenv("MODEL_SIZE", "small")
DEVICE = os.getenv("DEVICE", "cpu")  # or "cuda"
COMPUTE_TYPE = "float16" if DEVICE == "cuda" else "int8"

# Download settings
MAX_AUDIO_LENGTH = int(os.getenv("MAX_AUDIO_LENGTH", "14400"))  # 4 hours default

async def download_audio(youtube_url: str, output_dir: str = "/tmp/audio") -> str:
    """
    Download audio from YouTube using yt-dlp.
    Returns path to downloaded audio file.
    """
    output_path = os.path.join(output_dir, "%(id)s.%(ext)s")

    cmd = [
        "yt-dlp",
        "-f", "bestaudio[ext=m4a]/bestaudio",
        "--extract-audio",
        "--audio-format", "mp3",
        "--audio-quality", "0",  # best quality
        "--max-downloads", "1",
        "--no-playlist",
        "-o", output_path,
        youtube_url
    ]

    process = await asyncio.create_subprocess_exec(
        *cmd,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )

    stdout, stderr = await process.communicate()

    if process.returncode != 0:
        raise Exception(f"Download failed: {stderr.decode()}")

    # Get the actual filename
    # yt-dlp renames the file, so we need to find it
    output_files = list(Path(output_dir).glob("*.mp3"))
    if not output_files:
        raise Exception("No audio file found after download")

    return str(output_files[-1])

def transcribe_audio(
    audio_path: str,
    language: str = "auto",
    model_size: str = None,
    task: str = "transcribe",
    vad_filter: bool = True
) -> dict:
    """
    Transcribe audio file using faster-whisper.
    """
    model_size = model_size or DEFAULT_MODEL_SIZE

    # Load model (can be cached in production)
    print(f"Loading Whisper model: {model_size} on {DEVICE}")
    model = WhisperModel(
        model_size,
        device=DEVICE,
        compute_type=COMPUTE_TYPE,
        download_root="/app/models"
    )

    # Transcribe
    start_time = time.time()

    segments, info = model.transcribe(
        audio_path,
        language=language if language != "auto" else None,
        task=task,
        vad_filter=vad_filter,
        word_timestamps=True
    )

    # Combine all segments
    text_parts = []
    full_duration = 0

    for segment in segments:
        text_parts.append(segment.text)
        full_duration = max(full_duration, segment.end)

    text = " ".join(text_parts).strip()
    processing_time = time.time() - start_time

    return {
        "text": text,
        "language": info.language,
        "language_probability": info.language_probability,
        "duration": full_duration,
        "processing_time": processing_time
    }

async def transcribe_youtube_video(
    youtube_url: str,
    language: str = "auto",
    model_size: str = None,
    task: str = "transcribe",
    vad_filter: bool = True,
    job_id: str = None,
    return_segments: bool = False
) -> dict:
    """
    Complete workflow: download + transcribe YouTube video.

    Args:
        return_segments: If True, returns individual segments for subtitle formatting
    """
    temp_dir = tempfile.mkdtemp(prefix="yt_transcribe_")
    audio_file = None

    try:
        # Download audio
        print(f"Downloading audio from {youtube_url}")
        audio_file = await download_audio(youtube_url, temp_dir)

        # Get file size for validation
        file_size = os.path.getsize(audio_file)
        print(f"Audio file size: {file_size / (1024*1024):.2f} MB")

        # Transcribe
        print(f"Starting transcription with model: {model_size or DEFAULT_MODEL_SIZE}")

        model_size = model_size or DEFAULT_MODEL_SIZE

        # Load model
        model = WhisperModel(
            model_size,
            device=DEVICE,
            compute_type=COMPUTE_TYPE,
            download_root="/app/models"
        )

        # Transcribe with segments
        start_time = time.time()

        segments, info = model.transcribe(
            audio_file,
            language=language if language != "auto" else None,
            task=task,
            vad_filter=vad_filter,
            word_timestamps=True
        )

        # Convert generator to list for re-use
        segments_list = list(segments)
        processing_time = time.time() - start_time

        # Calculate duration and combine text
        full_duration = max((seg.end for seg in segments_list), default=0)
        text = " ".join([seg.text.strip() for seg in segments_list])

        result = {
            "text": text,
            "language": info.language,
            "language_probability": info.language_probability,
            "duration": full_duration,
            "processing_time": processing_time,
            "video_url": youtube_url,
            "audio_file": audio_file
        }

        # Include segments if requested
        if return_segments:
            result["segments"] = segments_list

        print(f"✅ Transcription completed in {processing_time:.2f}s")
        print(f"   Duration: {full_duration:.2f}s")
        print(f"   Language: {info.language} (confidence: {info.language_probability:.2f})")
        print(f"   Text length: {len(text)} chars")

        return result

    finally:
        # Cleanup
        if audio_file and os.path.exists(audio_file):
            os.remove(audio_file)
        if os.path.exists(temp_dir):
            os.rmdir(temp_dir)
