#!/bin/bash
# Whisper Local - Transcribe audio files using local Whisper model
# Usage: transcribe.sh <audio_file> [options]

set -e

# Defaults
MODEL="${WHISPER_MODEL:-medium}"
OUTPUT_FORMAT="txt"
OUTPUT_DIR="${WHISPER_OUTPUT_DIR:-.}"
LANGUAGE=""
TRANSLATE=false
OUTPUT_FILE=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Help function
show_help() {
  cat << EOF
🎙️  Whisper Local - Transcribe audio files locally

Usage: transcribe.sh <audio_file> [options]

Arguments:
  audio_file          Path to audio file (mp3, mp4, m4a, wav, webm, etc.)

Options:
  --model MODEL       Whisper model: tiny, base, small, medium, large (default: medium)
  --out FILE          Output file path (default: auto-generated)
  --format FORMAT     Output format: txt, srt, vtt, json (default: txt)
  --lang LANG         Language code (en, ru, es, etc. - auto-detect if empty)
  --translate         Translate to English
  --output-dir DIR    Output directory (default: current directory)
  -h, --help          Show this help

Examples:
  transcribe.sh audio.mp3
  transcribe.sh voice.m4a --model small --out transcript.txt
  transcribe.sh video.mp4 --format srt --lang ru
  transcribe.sh spanish.mp3 --translate

Model sizes:
  tiny   39MB   ⚡⚡⚡  Fastest
  base   74MB   ⚡⚡    Quick
  small  244MB  ⚡     Balanced
  medium 769MB  -      Accurate (default)
  large  1550MB 🐌     Best quality

EOF
  exit 0
}

# Parse arguments
if [ $# -eq 0 ]; then
  show_help
fi

AUDIO_FILE="$1"
shift

while [[ $# -gt 0 ]]; do
  case $1 in
    --model)
      MODEL="$2"
      shift 2
      ;;
    --out)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    --format)
      OUTPUT_FORMAT="$2"
      shift 2
      ;;
    --lang)
      LANGUAGE="$2"
      shift 2
      ;;
    --translate)
      TRANSLATE=true
      shift
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

# Check if audio file exists
if [ ! -f "$AUDIO_FILE" ]; then
  echo -e "${RED}Error: Audio file not found: $AUDIO_FILE${NC}"
  exit 1
fi

# Check if whisper is installed
if ! command -v whisper &> /dev/null; then
  echo -e "${RED}Error: whisper command not found${NC}"
  echo -e "${YELLOW}Install with: uv tool install whisper-cli${NC}"
  echo -e "${YELLOW}Or: pip install openai-whisper${NC}"
  exit 1
fi

# Build command
CMD="whisper \"$AUDIO_FILE\" --model $MODEL --output_format $OUTPUT_FORMAT --output_dir \"$OUTPUT_DIR\""

# Add language if specified
if [ -n "$LANGUAGE" ]; then
  CMD="$CMD --language $LANGUAGE"
fi

# Add translate flag if needed
if [ "$TRANSLATE" = true ]; then
  CMD="$CMD --task translate"
fi

# Print info
echo -e "${GREEN}🎙️  Transcribing:${NC} $AUDIO_FILE"
echo -e "${GREEN}📦 Model:${NC} $MODEL"
echo -e "${GREEN}📄 Format:${NC} $OUTPUT_FORMAT"
if [ -n "$LANGUAGE" ]; then
  echo -e "${GREEN}🌍 Language:${NC} $LANGUAGE"
fi
if [ "$TRANSLATE" = true ]; then
  echo -e "${GREEN}🔄 Task:${NC} translate to English"
fi
echo ""

# Run whisper
eval $CMD

# Find output file
AUDIO_BASENAME=$(basename "$AUDIO_FILE" | sed 's/\.[^.]*$//')
OUTPUT_PATTERN="$OUTPUT_DIR/${AUDIO_BASENAME}.*.${OUTPUT_FORMAT}"

# Check if output file was created
if compgen -G "$OUTPUT_PATTERN" > /dev/null; then
  OUTPUT=$(ls $OUTPUT_PATTERN | head -n 1)
  echo ""
  echo -e "${GREEN}✅ Transcription saved to:${NC} $OUTPUT"

  # Show preview if txt
  if [ "$OUTPUT_FORMAT" = "txt" ] && [ -z "$OUTPUT_FILE" ]; then
    echo ""
    echo -e "${YELLOW}📝 Preview (first 10 lines):${NC}"
    head -n 10 "$OUTPUT"
    echo -e "${YELLOW}...${NC}"
  fi

  # Copy to custom output file if specified
  if [ -n "$OUTPUT_FILE" ]; then
    cp "$OUTPUT" "$OUTPUT_FILE"
    echo -e "${GREEN}✅ Also saved to:${NC} $OUTPUT_FILE"
  fi
else
  echo -e "${RED}❌ Error: Output file not created${NC}"
  exit 1
fi
