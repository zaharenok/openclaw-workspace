#!/usr/bin/env bash
#
# OpenAI Whisper API Transcription Script
# Transcribes audio files using OpenAI's Whisper API
#

set -euo pipefail

# Default values
OUTPUT_FORMAT="text"
MODEL="whisper-1"
LANGUAGE=""  # Auto-detect if empty
API_KEY="${OPENAI_API_KEY:-}"

# Help message
show_help() {
  cat << EOF
Usage: transcribe.sh [OPTIONS] <audio_file>

Transcribe audio file using OpenAI Whisper API.

Arguments:
  audio_file              Path to audio file (mp3, mp4, mpeg, mpga, m4a, wav, webm)

Options:
  --out FILE             Output transcript to file instead of stdout
  --model MODEL           Whisper model: whisper-1 (default)
  --lang CODE             Language code (en, es, ru, etc.) or auto-detect
  --api-key KEY           OpenAI API key (or set OPENAI_API_KEY env var)

Environment:
  OPENAI_API_KEY          OpenAI API key (required)

Examples:
  # Transcribe and print to stdout
  transcribe.sh voice.ogg

  # Transcribe to file
  transcribe.sh voice.ogg --out transcript.txt

  # Transcribe with language hint
  transcribe.sh voice.ogg --lang ru

  # With API key
  transcribe.sh voice.ogg --api-key sk-...

EOF
}

# Parse arguments
OUTPUT_FILE=""
AUDIO_FILE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --out)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    --model)
      MODEL="$2"
      shift 2
      ;;
    --lang)
      LANGUAGE="$2"
      shift 2
      ;;
    --api-key)
      API_KEY="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    -*)
      echo "ERROR: Unknown option: $1" >&2
      show_help
      exit 1
      ;;
    *)
      AUDIO_FILE="$1"
      shift
      ;;
  esac
done

# Validate
if [[ -z "$AUDIO_FILE" ]]; then
  echo "ERROR: No audio file specified" >&2
  show_help
  exit 1
fi

if [[ ! -f "$AUDIO_FILE" ]]; then
  echo "ERROR: File not found: $AUDIO_FILE" >&2
  exit 1
fi

if [[ -z "$API_KEY" ]]; then
  echo "ERROR: OPENAI_API_KEY not set. Use --api-key or set environment variable." >&2
  exit 1
fi

# Build request
URL="https://api.openai.com/v1/audio/transcriptions"

# Prepare curl command
CURL_CMD=(curl -s -X POST "$URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@$AUDIO_FILE" \
  -F "model=$MODEL")

if [[ -n "$LANGUAGE" ]]; then
  CURL_CMD+=(-F "language=$LANGUAGE")
fi

if [[ "$OUTPUT_FORMAT" == "verbose_json" ]]; then
  CURL_CMD+=(-F "response_format=$OUTPUT_FORMAT")
fi

# Execute request
RESPONSE=$("${CURL_CMD[@]}" 2>&1)

# Check for errors
if [[ $RESPONSE =~ error ]]; then
  echo "ERROR: API request failed" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

# Extract text from JSON response (if JSON format)
TRANSCRIPT=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('text', ''))" 2>/dev/null || echo "$RESPONSE")

# Output
if [[ -n "$OUTPUT_FILE" ]]; then
  echo "$TRANSCRIPT" > "$OUTPUT_FILE"
  echo "✓ Transcription saved to: $OUTPUT_FILE" >&2
else
  echo "$TRANSCRIPT"
fi

exit 0
