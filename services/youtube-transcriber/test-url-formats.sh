#!/bin/bash

# Test different YouTube URL formats

API_KEY="${API_KEY:-your-secret-api-key}"
BASE_URL="${BASE_URL:-http://localhost:8000}"

VIDEO_ID="dQw4w9WgXcQ"

echo "🎬 Testing Different YouTube URL Formats"
echo "========================================"
echo ""

# Array of different URL formats
declare -a URLs=(
    "https://www.youtube.com/watch?v=${VIDEO_ID}"
    "https://youtu.be/${VIDEO_ID}"
    "https://youtube.com/shorts/${VIDEO_ID}"
    "https://www.youtube.com/embed/${VIDEO_ID}"
    "https://m.youtube.com/watch?v=${VIDEO_ID}"
    "https://www.youtube.com/watch?v=${VIDEO_ID}&t=30s"
    "https://www.youtube.com/watch?v=${VIDEO_ID}&list=PLxxx"
)

for url in "${URLS[@]}"; do
    echo "Testing: $url"

    response=$(curl -s -X POST "$BASE_URL/transcribe" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"url\": \"$url\",
            \"format\": \"text\",
            \"model\": \"tiny\"
        }")

    # Check if video_id matches
    returned_id=$(echo "$response" | jq -r '.video_id // empty')

    if [ "$returned_id" == "$VIDEO_ID" ]; then
        echo "✅ PASS - Video ID extracted correctly: $returned_id"
    else
        echo "❌ FAIL - Expected: $VIDEO_ID, Got: $returned_id"
    fi

    echo ""
done

echo "========================================"
echo "✅ URL format testing complete!"
