#!/bin/bash
# Craving & Trigger Log
# Usage: ./craving-log.sh "trigger description"

set -e

WORKSPACE="/home/node/.openclaw/workspace"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"
LOG_FILE="$DATA_DIR/cravings.json"

# Create data directory if it doesn't exist
mkdir -p "$DATA_DIR"

# Initialize log if doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    echo '{"cravings": []}' > "$LOG_FILE"
fi

function show_help() {
    echo "📝 Craving & Trigger Log"
    echo ""
    echo "Usage: $0 [command] [args]"
    echo ""
    echo "Commands:"
    echo "  log \"description\"    Log a craving/trigger"
    echo "  list                   Show recent cravings"
    echo "  analyze                Analyze patterns"
    echo "  help                   Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 log \"stress from work, alone at home\""
    echo "  $0 log \"social pressure at bar, friends drinking\""
    echo "  $0 list"
    echo "  $0 analyze"
}

function log_craving() {
    local description="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local date_only=$(date -u +"%Y-%m-%d")

    if [ -z "$description" ]; then
        echo "❌ Error: Please provide a description"
        echo "Usage: $0 log \"description\""
        exit 1
    fi

    # Add to log
    local json=$(cat "$LOG_FILE")
    echo "$json" | jq --arg ts "$timestamp" --arg date "$date_only" --arg desc "$description" \
        '.cravings += [{"timestamp": $ts, "date": $date, "description": $desc}]' > "$LOG_FILE"

    echo "✅ Craving logged"
    echo "📅 $timestamp"
    echo "📝 $description"
    echo ""
    echo "💡 Remember the 4 Ds:"
    echo "   1️⃣ DELAY — Wait 15 minutes"
    echo "   2️⃣ DISTRACT — Do something else"
    echo "   3️⃣ DRINK WATER — Hydrate"
    echo "   4️⃣ BREATHE — 4-7-8 technique"
}

function list_recent() {
    local count=${2:-10}
    local json=$(cat "$LOG_FILE")
    local total=$(echo "$json" | jq -r '.cravings | length')

    if [ "$total" -eq 0 ]; then
        echo "✨ No cravings logged yet!"
        return 0
    fi

    echo "📝 Recent Cravings (last $count)"
    echo "==============================="

    # Show last N entries (reversed)
    echo "$json" | jq -r '.cravings | reverse | .[0:'$count'][] |
        "📅 \(.date) 🕐 \(.timestamp[11:19])\n   \(.description)\n"' | head -n $((count * 3))

    echo ""
    echo "Total logged: $total"
}

function analyze_patterns() {
    local json=$(cat "$LOG_FILE")
    local total=$(echo "$json" | jq -r '.cravings | length')

    if [ "$total" -eq 0 ]; then
        echo "✨ No cravings to analyze yet. Log some first!"
        return 0
    fi

    echo "🔍 Craving Pattern Analysis"
    echo "==========================="
    echo ""

    # Count by date
    echo "📅 Cravings by date:"
    echo "$json" | jq -r '.cravings | group_by(.date) | map({date: .[0].date, count: length}) |
        sort_by(.count) | reverse | .[:5][] |
        "   \(.date): \(.count)x"'

    echo ""

    # Extract common keywords
    echo "🔑 Common triggers:"
    echo "$json" | jq -r '.cravings[].description | tolower | split(" ") | .[]' |
        sort | uniq -c | sort -rn | head -10 |
        awk '{print "   " $2 ": " $1 "x"}'

    echo ""

    # Extract times (hour of day)
    echo "🕐 Time of day patterns:"
    echo "$json" | jq -r '.cravings[].timestamp | .[11:13]' |
        sort | uniq -c | sort -rn |
        awk '{print "   " $2 ":00 - " $1 "x cravings"}'

    echo ""

    # HALT analysis
    echo "🛡️ HALT Check (Common triggers):"
    local halt_keywords=("hungry" "angry" "lonely" "tired" "stress" "bored" "sad" "anxious")

    for keyword in "${halt_keywords[@]}"; do
        local count=$(echo "$json" | jq -r ".cravings[].description | tolower | select(test(\"$keyword\"))" | wc -l)
        if [ "$count" -gt 0 ]; then
            echo "   $keyword: $countx"
        fi
    done

    echo ""
    echo "💡 Recommendations based on patterns:"
    echo "$json" | jq -r '.cravings[].description | tolower' |
        grep -q "stress" && echo "   • Stress is a trigger — consider breathing exercises, walks"
    echo "$json" | jq -r '.cravings[].description | tolower' |
        grep -q "lonely\|alone" && echo "   • Isolation triggers cravings — reach out to support network"
    echo "$json" | jq -r '.cravings[].description | tolower' |
        grep -q "social\|friend\|bar" && echo "   • Social pressure — plan responses and exits in advance"
}

# Main
case "${1:-help}" in
    log)
        log_craving "$2"
        ;;
    list|recent)
        list_recent "$@"
        ;;
    analyze|patterns)
        analyze_patterns
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
