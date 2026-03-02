#!/bin/bash

# Interactive GitHub Repository Creation Script
# Usage: ./create-repo-with-token.sh

export PATH="$HOME/gh_2.40.1_linux_amd64/bin:$PATH"

REPO_NAME="beautiful_mindmap"
DESCRIPTION="Beautiful mind map components for React with shadcn/ui integration"
VISIBILITY="public"

echo "🚀 GitHub Repository Creator"
echo "=============================="
echo ""
echo "Repository: $REPO_NAME"
echo "Description: $DESCRIPTION"
echo "Visibility: $VISIBILITY"
echo ""

# Check if token is provided
if [ -z "$GITHUB_TOKEN" ]; then
    echo "🔑 GitHub token not found in environment"
    echo ""
    echo "To create a repository, you need a GitHub Personal Access Token:"
    echo "  1. Go to: https://github.com/settings/tokens"
    echo "  2. Click 'Generate new token (classic)'"
    echo "  3. Select scopes: repo (full control)"
    echo "  4. Generate and copy the token"
    echo ""
    echo "Then run:"
    echo "  export GITHUB_TOKEN='your_token_here'"
    echo "  $0"
    echo ""
    exit 1
fi

# Authenticate with token
echo "🔐 Authenticating with GitHub..."
echo "$GITHUB_TOKEN" | gh auth login --with-token

if [ $? -ne 0 ]; then
    echo "❌ Authentication failed"
    exit 1
fi

echo "✅ Authenticated as: $(gh api user --jq '.login')"
echo ""

# Create repository
echo "📦 Creating repository..."
gh repo create "$REPO_NAME" \
    --$VISIBILITY \
    --description "$DESCRIPTION" \
    --source=. \
    --remote=origin \
    --push

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Repository created successfully!"
    echo ""
    echo "🔗 Repository URL:"
    gh repo view "$REPO_NAME" --web
    echo ""
    echo "📊 Repository info:"
    gh repo view "$REPO_NAME"
else
    echo ""
    echo "❌ Failed to create repository"
    echo "Possible issues:"
    echo "  - Repository name already exists"
    echo "  - Invalid token permissions"
    echo "  - Network connection issues"
    exit 1
fi
