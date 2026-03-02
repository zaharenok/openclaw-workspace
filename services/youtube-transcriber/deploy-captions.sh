#!/bin/bash

# Quick Deploy Script for YouTube Transcript API (Captions)

set -e

echo "⚡ YouTube Transcript API - Instant Captions Deploy"
echo "===================================================="
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cat > .env << EOF
API_KEY=change-me-to-secure-key
EOF
    echo "⚠️  API_KEY set to default. Change it for production!"
    echo "   Edit: nano .env"
    echo ""
fi

# Build and start
echo "🐳 Building Docker image..."
docker-compose -f docker-compose.captions.yml build

echo "▶️  Starting service..."
docker-compose -f docker-compose.captions.yml up -d

# Wait for service
echo "⏳ Waiting for service to start..."
sleep 3

# Check health
echo "📊 Checking service health..."
curl -s http://localhost:8000/ | jq .

echo ""
echo "✅ Deployment complete!"
echo ""
echo "⚡ Service running at: http://localhost:8000"
echo "📚 API docs: http://localhost:8000/docs"
echo ""
echo "🧪 Test the API:"
echo "   curl -X POST http://localhost:8000/transcribe \\"
echo "     -H \"Authorization: Bearer change-me-to-secure-key\" \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     -d '{\"url\": \"https://youtu.be/dQw4w9WgXcQ\"}'"
echo ""
echo "📝 View logs:"
echo "   docker-compose -f docker-compose.captions.yml logs -f"
