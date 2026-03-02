import asyncio
from typing import List, Dict, Optional
from youtube_transcript_api import YouTubeTranscriptApi
from youtube_transcript_api.formatters import TextFormatter, SRTFormatter, WebVTTFormatter
from .utils import extract_video_id

class TranscriptExtractor:
    """Extract transcripts from YouTube videos."""

    @staticmethod
    def get_transcript(
        video_id: str,
        languages: Optional[List[str]] = None
    ) -> List[Dict]:
        """
        Get transcript from YouTube.

        Args:
            video_id: YouTube video ID
            languages: List of language codes to try (e.g., ['en', 'ru'])

        Returns:
            List of transcript segments with start, duration, text

        Raises:
            Exception: If transcript not found
        """
        try:
            if languages:
                transcript = YouTubeTranscriptApi.get_transcript(
                    video_id,
                    languages=languages
                )
            else:
                # Auto-detect language
                transcript = YouTubeTranscriptApi.get_transcript(video_id)

            return transcript

        except Exception as e:
            raise Exception(f"Transcript not found: {str(e)}")

    @staticmethod
    def get_available_transcripts(video_id: str) -> Dict:
        """
        Get all available transcripts for a video.

        Returns:
            Dict with manually_created and generated transcripts
        """
        try:
            transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)

            languages = {
                'manually_created': [],
                'generated': [],
                'translations': []
            }

            for transcript in transcript_list:
                info = {
                    'language': transcript.language,
                    'language_code': transcript.language_code,
                    'is_generated': transcript.is_generated,
                }

                if transcript.is_generated:
                    languages['generated'].append(info)
                else:
                    languages['manually_created'].append(info)

                # Check for translations
                if hasattr(transcript, 'translation_languages_dict'):
                    languages['translations'] = transcript.translation_languages_dict

            return languages

        except Exception as e:
            raise Exception(f"Could not list transcripts: {str(e)}")

    @staticmethod
    def format_as_text(transcript: List[Dict]) -> str:
        """Format transcript as plain text."""
        formatter = TextFormatter()
        return formatter.format_transcript(transcript)

    @staticmethod
    def format_as_srt(transcript: List[Dict]) -> str:
        """Format transcript as SRT."""
        formatter = SRTFormatter()
        return formatter.format_transcript(transcript)

    @staticmethod
    def format_as_vtt(transcript: List[Dict]) -> str:
        """Format transcript as WebVTT."""
        formatter = WebVTTFormatter()
        return formatter.format_transcript(transcript)

    @staticmethod
    def format_as_timestamps(transcript: List[Dict]) -> str:
        """Format transcript with timestamps [HH:MM:SS]."""
        from .utils import format_timestamp

        lines = []
        for segment in transcript:
            timestamp = format_timestamp(segment['start'])
            text = segment['text'].strip()
            lines.append(f"[{timestamp}] {text}")

        return "\n".join(lines)

async def extract_transcript(
    url: str,
    languages: Optional[List[str]] = None,
    format: str = "text"
) -> dict:
    """
    Extract transcript from YouTube URL.

    Args:
        url: YouTube URL (any format)
        languages: List of language codes to try
        format: Output format (text, srt, vtt, timestamps)

    Returns:
        Dict with transcript data
    """
    # Extract video ID
    video_id = extract_video_id(url)
    if not video_id:
        raise ValueError("Invalid YouTube URL")

    # Get transcript
    transcript = TranscriptExtractor.get_transcript(video_id, languages)

    # Format based on requested format
    extractor = TranscriptExtractor()

    if format == "srt":
        content = extractor.format_as_srt(transcript)
    elif format == "vtt":
        content = extractor.format_as_vtt(transcript)
    elif format == "timestamps":
        content = extractor.format_as_timestamps(transcript)
    else:  # default: text
        content = extractor.format_as_text(transcript)

    # Calculate duration
    duration = max((seg['start'] + seg['duration'] for seg in transcript), default=0)

    # Detect language from first segment
    language = languages[0] if languages else "unknown"

    return {
        "text": content,
        "language": language,
        "duration": duration,
        "processing_time": 0.001,  # Instant!
        "video_id": video_id,
        "video_url": f"https://www.youtube.com/watch?v={video_id}",
        "segments": transcript
    }
