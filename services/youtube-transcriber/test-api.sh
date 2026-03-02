#!/bin/bash

# YouTube Transcriber API Test Script

API_KEY="${API_KEY:-your-secret-api-key}"
BASE_URL="${BASE_URL:-http://localhost:8000}"

echo "🎬 YouTube Transcriber API Test"
echo "================================"
echo "URL: $BASE_URL"
echo ""

# Test 1: Health check
echo "📊 Test 1: Health Check"
curl -s "$BASE_URL/" | jq .
echo ""
echo ""

# Test 2: Transcribe a short video
echo "🎯 Test 2: Transcribe Video"
echo "URL: https://www.youtube.com/watch?v=dQw4w9WgXcQ (Rick Roll - short)"

curl -X POST "$BASE_URL/transcribe" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "language": "auto",
    "model": "tiny",
    "vad_filter": true
  }' | jq .

echo ""
echo "✅ Tests completed!"
