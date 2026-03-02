#!/bin/bash
#
# LinkedIn MCP - CLI Wrapper
# Удобная обёртка для LinkedIn MCP через mcporter
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINKEDIN_MCP="/root/.openclaw/workspace/skills/linkedin-automation/linkedin_mcp.py"

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

show_help() {
    cat << EOF
${BLUE}🔗 LinkedIn MCP - Monitor Posts, Comments & Analytics${NC}

${YELLOW}Usage:${NC}
  $0 <command> [options]

${YELLOW}Commands:${NC}
  feed [count]         - Read LinkedIn feed (default: 5 posts)
  check-session         - Verify LinkedIn session is valid
  analytics [count]     - Get engagement analytics (default: 10 posts)
  profile-stats         - Get profile statistics
  scan-likes [count]    - Monitor new likes (default: 15 items)
  activity <url> [n]   - Scrape profile activity

${YELLOW}Examples:${NC}
  $0 feed 10
  $0 check-session
  $0 analytics 20
  $0 scan-likes 25
  $0 activity "https://linkedin.com/in/username" 10

${YELLOW}Via mcporter:${NC}
  mcporter call linkedin.read_feed count:10
  mcporter call linkedin.check_session
  mcporter call linkedin.analytics count:20

${YELLOW}Debug mode:${NC}
  LINKEDIN_DEBUG=1 $0 feed

EOF
}

# Проверка зависимостей
check_dependencies() {
    if ! python3 -c "import sys; sys.path.insert(0, '/root/.openclaw/workspace/skills/linkedin-automation/scripts/lib'); import browser" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Warning: LinkedIn dependencies not fully installed${NC}"
        echo "Run: cd /root/.openclaw/workspace/skills/linkedin-automation && ./setup-linkedin-session.sh"
    fi
}

# Вызов Python MCP
call_mcp() {
    local tool=$1
    shift
    local params=("$@")
    
    # Формируем JSON параметры
    local param_json="{}"
    
    case "$tool" in
        feed)
            local count=${params[0]:-5}
            param_json=$(python3 -c "import json; print(json.dumps({'count': $count}))")
            ;;
        analytics)
            local count=${params[0]:-10}
            param_json=$(python3 -c "import json; print(json.dumps({'count': $count}))")
            ;;
        scan-likes)
            local count=${params[0]:-15}
            param_json=$(python3 -c "import json; print(json.dumps({'count': $count}))")
            ;;
        activity)
            local profile_url="${params[0]}"
            local count=${params[1]:-5}
            param_json=$(python3 -c "import json; print(json.dumps({'profileUrl': '$profile_url', 'count': $count}))")
            ;;
        check-session|profile-stats)
            param_json="{}"
            ;;
    esac
    
    # Вызываем Python MCP напрямую
    python3 -c "
import json
import sys
sys.path.insert(0, '${LINKEDIN_MCP%/*}')

# Импортируем функции из linkedin_mcp
exec(open('${LINKEDIN_MCP}').read())

# Вызываем нужный инструмент
result = handle_tool_call('$tool', $param_json)

# Выводим результат
if result.get('success'):
    if result.get('data'):
        print(json.dumps(result['data'], indent=2))
    else:
        print(json.dumps({'status': 'success'}, indent=2))
    sys.exit(0)
else:
    print(json.dumps({'error': result.get('error')}, indent=2), file=sys.stderr)
    sys.exit(1)
"
}

# Main
check_dependencies

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

if [[ -z "$1" ]]; then
    show_help
    exit 1
fi

# Выполняем команду
echo -e "${BLUE}🔍 LinkedIn MCP:${NC} $1 ${@:2}"
echo ""

call_mcp "$@" 2>&1

exit_code=$?

if [[ $exit_code -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}✅ Success${NC}"
else
    echo ""
    echo -e "${RED}❌ Failed with exit code $exit_code${NC}"
fi

exit $exit_code
