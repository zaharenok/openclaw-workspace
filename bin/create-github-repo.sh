#!/bin/bash

# Create GitHub Repository Script
# Usage: ./create-github-repo.sh REPO_NAME [DESCRIPTION] [PRIVATE]

REPO_NAME="${1:-beautiful_mindmap}"
DESCRIPTION="${2:-Beautiful mind map components for React with shadcn/ui integration}"
PRIVATE="${3:-public}"

echo "🚀 Creating GitHub repository: $REPO_NAME"
echo "📝 Description: $DESCRIPTION"
echo "🔒 Visibility: $PRIVATE"
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo ""
    echo "Install options:"
    echo "  Ubuntu/Debian: sudo apt install gh"
    echo "  macOS: brew install gh"
    echo "  Or visit: https://cli.github.com/"
    echo ""
    echo "After installing, run: gh auth login"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub"
    echo "Run: gh auth login"
    exit 1
fi

# Create repository
echo "📦 Creating repository..."
gh repo create "$REPO_NAME" \
    --$PRIVATE \
    --description "$DESCRIPTION" \
    --source=. \
    --remote=origin \
    --push

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Repository created successfully!"
    echo "🔗 URL: https://github.com/$(gh api user --jq '.login')/$REPO_NAME"
else
    echo ""
    echo "❌ Failed to create repository"
    exit 1
fi
