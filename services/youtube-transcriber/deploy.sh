#!/bin/bash

# Quick Deploy Script for YouTube Transcriber

set -e

echo "🚀 YouTube Transcriber - Quick Deploy"
echo "======================================"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env and set your API_KEY!"
    echo "   Run: nano .env"
    exit 1
fi

# Source environment
export $(cat .env | grep -v '^#' | xargs)

# Build Docker image
echo "🐳 Building Docker image..."
docker-compose build

# Start service
echo "▶️  Starting service..."
docker-compose up -d

# Wait for service to be ready
echo "⏳ Waiting for service to start..."
sleep 5

# Check health
echo "📊 Checking service health..."
curl -s http://localhost:8000/ | jq .

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📍 Service running at: http://localhost:8000"
echo "📚 API docs: http://localhost:8000/docs"
echo ""
echo "🧪 Test the API:"
echo "   ./test-api.sh"
echo ""
echo "📝 View logs:"
echo "   docker-compose logs -f"
