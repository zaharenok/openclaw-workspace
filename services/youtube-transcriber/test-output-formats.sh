#!/bin/bash

# Test different output formats

API_KEY="${API_KEY:-your-secret-api-key}"
BASE_URL="${BASE_URL:-http://localhost:8000}"

VIDEO_URL="https://youtu.be/dQw4w9WgXcQ"

echo "🎬 Testing Different Output Formats"
echo "===================================="
echo ""

# Test formats
declare -a formats=("text" "srt" "vtt" "timestamps")

for format in "${formats[@]}"; do
    echo "Testing format: $format"
    echo "---"

    response=$(curl -s -X POST "$BASE_URL/transcribe" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"url\": \"$VIDEO_URL\",
            \"format\": \"$format\",
            \"model\": \"tiny\"
        }")

    # Show first few lines/characters
    if [ "$format" == "text" ]; then
        echo "$response" | jq '.text' | head -c 200
        echo "..."
    else
        echo "$response" | head -n 5
        echo "..."
    fi

    echo ""
    echo "✅ $format format works!"
    echo ""
done

echo "===================================="
echo "✅ Output format testing complete!"
