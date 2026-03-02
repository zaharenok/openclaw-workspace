#!/bin/bash
# Save YouTube transcript to knowledge base
# Usage: ./save-transcript.sh <json-response-file>

INPUT="$1"
KB_DIR="/home/node/.openclaw/workspace/knowledge/youtube"

if [ -z "$INPUT" ] || [ ! -f "$INPUT" ]; then
  echo "❌ Usage: $0 <json-response-file>"
  exit 1
fi

mkdir -p "$KB_DIR"

# Try Python first (most reliable)
if command -v python3 &> /dev/null; then
  eval "$(python3 - "$INPUT" "$KB_DIR" << 'PYEOF'
import json
import sys
import re
from datetime import datetime

with open(sys.argv[1], 'r') as f:
    data = json.load(f)

TITLE = data.get('title', 'Unknown')
VIDEO_ID = data.get('video_id', data.get('videoId', 'unknown'))
TEXT = data.get('text', data.get('transcript', data.get('content', '')))
LANGUAGE = data.get('language', 'unknown')
REQUEST_ID = data.get('request_id', 'N/A')
KB_DIR = sys.argv[2]

if not TEXT:
    print("echo '❌ No transcript text found in response'")
    sys.exit(1)

DATE = datetime.now().strftime('%Y-%m-%d')
SAFE_TITLE = re.sub(r'[^a-z0-9]+', '-', TITLE.lower()).strip('-')
FILENAME = f"{DATE}-{VIDEO_ID}-{SAFE_TITLE}.md"
FILEPATH = f"{KB_DIR}/{FILENAME}"

with open(FILEPATH, 'w') as f:
    f.write(f"# {TITLE}\n\n")
    f.write(f"**Source:** [YouTube](https://youtube.com/watch?v={VIDEO_ID})\n")
    f.write(f"**Video ID:** {VIDEO_ID}\n")
    f.write(f"**Language:** {LANGUAGE}\n")
    f.write(f"**Date Added:** {DATE}\n\n")
    f.write("---\n\n")
    f.write("## Transcript\n\n")
    f.write(f"{TEXT}\n\n")
    f.write("---\n\n")
    f.write("## Metadata\n\n")
    f.write(f"- **Request ID:** {REQUEST_ID}\n")
    f.write(f"- **Processing Date:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

word_count = len(TEXT.split())
char_count = len(TEXT)

print(f"echo '✅ Transcript saved to:'")
print(f"echo '   {FILEPATH}'")
print(f"echo ''")
print(f"echo '📊 Stats:'")
print(f"echo '   Title: {TITLE}'")
print(f"echo '   Length: {word_count} words'")
print(f"echo '   Chars: {char_count} characters'")
PYEOF
)"
  exit $?
fi

# Fallback: Simple grep-based parsing
echo "⚠️  Python not available, using basic parsing..."
TITLE=$(grep -oP '"title":\s*"\K[^"]*' "$INPUT" 2>/dev/null || echo "Unknown")
VIDEO_ID=$(grep -oP '"video_id":\s*"\K[^"]*' "$INPUT" 2>/dev/null || grep -oP '"videoId":\s*"\K[^"]*' "$INPUT" 2>/dev/null || echo "unknown")

# Extract text (basic, may not work for complex JSON)
TEXT=$(sed -n '/"text"/s/.*"text"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$INPUT" | head -1)

if [ -z "$TEXT" ]; then
  echo "❌ Could not extract text. Install python3 for better parsing."
  exit 1
fi

DATE=$(date +%Y-%m-%d)
SAFE_TITLE=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
FILENAME="${DATE}-${VIDEO_ID}-${SAFE_TITLE}.md"
FILEPATH="$KB_DIR/$FILENAME"

cat > "$FILEPATH" << EOF
# ${TITLE}

**Source:** [YouTube](https://youtube.com/watch?v=${VIDEO_ID})
**Video ID:** ${VIDEO_ID}
**Date Added:** ${DATE}

---

## Transcript

${TEXT}

---

*Note: Full parsing requires python3*
EOF

echo "✅ Transcript saved to:"
echo "   $FILEPATH"
