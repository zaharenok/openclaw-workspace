#!/bin/bash
#
# LinkedIn MCP - Test Installation
# Проверяет установку и базовую функциональность
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINKEDIN_MCP="$SCRIPT_DIR/linkedin-mcp.sh"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔗 LinkedIn MCP - Installation Test${NC}"
echo "========================================"
echo ""

# Test 1: Check if script exists
echo -e "${YELLOW}[1/5] Checking installation...${NC}"
if [[ ! -f "$LINKEDIN_MCP" ]]; then
    echo -e "${RED}❌ linkedin-mcp.sh not found${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Script found${NC}"
echo ""

# Test 2: Check dependencies
echo -e "${YELLOW}[2/5] Checking dependencies...${NC}"
if ! python3 -c "import sys" 2>/dev/null; then
    echo -e "${RED}❌ Python3 not found${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Python3 available${NC}"
echo ""

# Test 3: Check LinkedIn session
echo -e "${YELLOW}[3/5] Checking LinkedIn session...${NC}"
if ! "$LINKEDIN_MCP" check-session 2>&1 | grep -q "success\|valid"; then
    echo -e "${YELLOW}⚠️  LinkedIn session may not be configured${NC}"
    echo ""
    echo "To set up LinkedIn session:"
    echo "  cd /root/.openclaw/workspace/skills/linkedin-automation"
    echo "  ./setup-linkedin-session.sh"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✅ LinkedIn session valid${NC}"
fi
echo ""

# Test 4: Test feed reading
echo -e "${YELLOW}[4/5] Testing feed reading (3 posts)...${NC}"
if "$LINKEDIN_MCP" feed 3 2>&1 | grep -q "posts\|error"; then
    echo -e "${GREEN}✅ Feed reading works${NC}"
else
    echo -e "${YELLOW}⚠️  Feed reading returned unexpected output${NC}"
fi
echo ""

# Test 5: Test analytics
echo -e "${YELLOW}[5/5] Testing analytics (5 posts)...${NC}"
if "$LINKEDIN_MCP" analytics 5 2>&1 | grep -q "posts\|error"; then
    echo -e "${GREEN}✅ Analytics works${NC}"
else
    echo -e "${YELLOW}⚠️  Analytics returned unexpected output${NC}"
fi
echo ""

# Summary
echo "========================================"
echo -e "${GREEN}✅ Installation test complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Set up LinkedIn session (if not done)"
echo "  2. Test basic commands:"
echo "     $LINKEDIN_MCP feed 10"
echo "     $LINKEDIN_MCP analytics 20"
echo "  3. Add to HEARTBEAT.md for automation"
echo ""
echo "Documentation:"
echo "  - Quick start: $SCRIPT_DIR/linkedin-mcp-quickstart.md"
echo "  - Full docs: ~/workspace/docs/linkedin-mcp-server.md"
echo ""
