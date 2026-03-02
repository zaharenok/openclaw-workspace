#!/usr/bin/env bash
#
# Voice Processor for OpenClaw Telegram
# Processes incoming voice messages: transcribe + respond + cleanup
# With fallback: Local Whisper -> OpenAI API
#

set -euo pipefail

# Configuration
TRANSCRIPTS_DIR="${HOME}/.openclaw/workspace/skills/voice-processor/transcripts"
WHISPER_LOCAL="/home/node/.openclaw/workspace/skills/local-whisper/scripts/transcribe.sh"
WHISPER_API="/home/node/.openclaw/workspace/skills/openai-whisper-api/scripts/transcribe.sh"
KEEP_HOURS=24
LOG="${TRANSCRIPTS_DIR}/processor.log"

# Prefer local whisper (change to "api" to always use API)
TRANSCRIPTION_MODE="${TRANSCRIPTION_MODE:-local}"  # local, api, or fallback

# Ensure directories exist
mkdir -p "$TRANSCRIPTS_DIR"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"
}

# Transcribe using local Whisper
transcribe_local() {
  local audio_file="$1"
  local transcript_file="$2"
  
  log "🎙️ Using LOCAL Whisper (free)..."
  
  # Set PYTHONPATH for local packages
  export PYTHONPATH="${HOME}/.openclaw/workspace/skills/local-whisper/lib:${PYTHONPATH:-}"
  
  if "$WHISPER_LOCAL" "$audio_file" --out "$transcript_file" --lang auto 2>&1 | tee -a "$LOG"; then
    log "✅ Local transcription successful"
    return 0
  else
    log "⚠️  Local transcription failed"
    return 1
  fi
}

# Transcribe using OpenAI API
transcribe_api() {
  local audio_file="$1"
  local transcript_file="$2"
  
  log "🌐 Using OpenAI API ($0.006/min)..."
  
  if "$WHISPER_API" "$audio_file" --out "$transcript_file" --lang auto 2>&1 | tee -a "$LOG"; then
    log "✅ API transcription successful"
    return 0
  else
    log "❌ API transcription failed"
    return 1
  fi
}

# Transcribe with fallback logic
transcribe() {
  local audio_file="$1"
  local transcript_file="$2"
  
  case "$TRANSCRIPTION_MODE" in
    local)
      if transcribe_local "$audio_file" "$transcript_file"; then
        return 0
      else
        log "❌ Local transcription failed and fallback disabled"
        return 1
      fi
      ;;
    api)
      transcribe_api "$audio_file" "$transcript_file"
      return $?
      ;;
    fallback)
      # Try local first, then API
      if transcribe_local "$audio_file" "$transcript_file"; then
        return 0
      elif transcribe_api "$audio_file" "$transcript_file"; then
        return 0
      else
        log "❌ Both transcription methods failed"
        return 1
      fi
      ;;
    *)
      log "❌ Unknown TRANSCRIPTION_MODE: $TRANSCRIPTION_MODE"
      return 1
      ;;
  esac
}

# Process a single voice message
process_voice() {
  local audio_file="$1"
  local message_id="$2"
  
  if [[ ! -f "$audio_file" ]]; then
    log "ERROR: File not found: $audio_file"
    return 1
  fi

  log "Processing voice message: $audio_file (msg: $message_id)"
  log "Transcription mode: $TRANSCRIPTION_MODE"

  # Transcribe
  local transcript_file="${TRANSCRIPTS_DIR}/${message_id}.txt"
  local timestamp=$(date '+%Y%m%d_%H%M%S')

  log "Transcribing..."
  if transcribe "$audio_file" "$transcript_file"; then
    local transcript=$(cat "$transcript_file")
    log "✓ Transcription complete: ${transcript:0:100}..."
    
    # Return transcript for response
    echo "$transcript"
    
    # Schedule cleanup
    local cleanup_time=$(($(date +%s) + (KEEP_HOURS * 3600)))
    echo "${cleanup_time}|${audio_file}|${transcript_file}" >> "${TRANSCRIPTS_DIR}/cleanup_queue.txt"
    log "✓ Scheduled cleanup in ${KEEP_HOURS}h"
    
    return 0
  else
    log "❌ Transcription failed for: $audio_file"
    return 1
  fi
}

# Cleanup old files
cleanup() {
  local now=$(date +%s)
  local queue_file="${TRANSCRIPTS_DIR}/cleanup_queue.txt"
  
  if [[ ! -f "$queue_file" ]]; then
    log "No cleanup queue found"
    return 0
  fi
  
  log "Running cleanup..."
  local cleaned=0
  
  while IFS='|' read -r cleanup_time audio_file transcript_file; do
    if [[ $now -ge $cleanup_time ]]; then
      log "Removing: $audio_file"
      rm -f "$audio_file" "$transcript_file" 2>/dev/null || true
      ((cleaned++))
    fi
  done < "$queue_file"
  
  # Update queue (remove cleaned entries)
  local temp_queue="${queue_file}.tmp"
  while IFS='|' read -r cleanup_time audio_file transcript_file; do
    if [[ $now -lt $cleanup_time ]]; then
      echo "${cleanup_time}|${audio_file}|${transcript_file}" >> "$temp_queue"
    fi
  done < "$queue_file"
  mv "$temp_queue" "$queue_file"
  
  log "✓ Cleanup complete: ${cleaned} files removed"
}

# Main
case "${1:-process}" in
  process)
    process_voice "$2" "$3"
    ;;
  cleanup)
    cleanup
    ;;
  *)
    echo "Usage: $0 {process|cleanup} [audio_file] [message_id]"
    exit 1
    ;;
esac
