#!/bin/bash
# Sobriety Day Tracker
# Usage: ./tracker.sh [days]
# Example: ./tracker.sh 30

set -e

WORKSPACE="/home/node/.openclaw/workspace"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"
TRACKER_FILE="$DATA_DIR/sobriety-tracker.json"

# Create data directory if it doesn't exist
mkdir -p "$DATA_DIR"

# Initialize tracker if doesn't exist
if [ ! -f "$TRACKER_FILE" ]; then
    echo '{"start_date": null, "current_streak": 0, "longest_streak": 0, "total_days": 0, "slips": []}' > "$TRACKER_FILE"
fi

function show_help() {
    echo "🚫 Sobriety Tracker"
    echo ""
    echo "Usage: $0 [command] [args]"
    echo ""
    echo "Commands:"
    echo "  start [days]      Start or restart sobriety counter (default: 0)"
    echo "  status            Show current stats"
    echo "  milestone [days]  Check if milestone reached"
    echo "  slip              Record a slip and reset"
    echo "  help              Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 start          # Start Day 1"
    echo "  $0 start 30       # Start with 30 days"
    echo "  $0 status         # Show progress"
    echo "  $0 milestone 30   # Check if 30-day milestone reached"
}

function start_sobriety() {
    local days=${1:-0}
    local start_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Calculate start date based on days
    if [ "$days" -gt 0 ]; then
        start_date=$(date -u -d "$days days ago" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v-${days}d +"%Y-%m-%dT%H:%M:%SZ")
    fi

    # Update tracker
    local json=$(cat "$TRACKER_FILE")
    echo "$json" | jq --arg start "$start_date" --argjson days "$days" \
        '.start_date = $start | .current_streak = $days | .longest_streak = (if $days > .longest_streak then $days else .longest_streak end)' > "$TRACKER_FILE"

    local day_num=$((days + 1))
    echo "🎉 Sobriety tracker started!"
    echo "📅 Start date: $start_date"
    echo "🔥 Current streak: $days days"
    echo "📍 Day $day_num"
}

function show_status() {
    local json=$(cat "$TRACKER_FILE")
    local start_date=$(echo "$json" | jq -r '.start_date')
    local current_streak=$(echo "$json" | jq -r '.current_streak')
    local longest_streak=$(echo "$json" | jq -r '.longest_streak')
    local total_days=$(echo "$json" | jq -r '.total_days')
    local slips=$(echo "$json" | jq -r '.slips | length')

    if [ "$start_date" = "null" ]; then
        echo "⚠️  Sobriety tracker not started. Use '$0 start' to begin."
        return 1
    fi

    local day_num=$((current_streak + 1))

    echo "🚫 Sobriety Status"
    echo "=================="
    echo "📍 Day $day_num"
    echo "🔥 Current streak: $current_streak days"
    echo "🏆 Longest streak: $longest_streak days"
    echo "📊 Total days: $total_days"
    echo "💫 Slips: $slips"
    echo "📅 Started: $start_date"
    echo ""

    # Calculate time-based milestones
    if [ "$current_streak" -ge 1 ]; then
        local hours=$((current_streak * 24))
        echo "⏰ That's $hours hours of freedom!"
    fi

    # Show upcoming milestone
    local next_milestone=1
    for m in 7 14 30 60 90 180 365; do
        if [ "$current_streak" -lt "$m" ]; then
            next_milestone=$m
            break
        fi
    done

    local days_until=$((next_milestone - current_streak))
    echo "🎯 Next milestone: $next_milestone days ($days_until days to go)"
}

function check_milestone() {
    local target=$1
    local json=$(cat "$TRACKER_FILE")
    local current_streak=$(echo "$json" | jq -r '.current_streak')

    if [ "$current_streak" -ge "$target" ]; then
        echo "🎉 MILESTONE REACHED: $target days!"
        echo "🏆 Incredible achievement!"

        # Show milestone-specific messages
        case $target in
            7)
                echo "📊 One week! Your brain is already healing."
                echo "💧 Sleep and focus are improving."
                ;;
            30)
                echo "🌟 One month! Your liver is repairing."
                echo "💪 Energy levels rising significantly."
                ;;
            90)
                echo "🚀 Three months! Mental clarity restored."
                echo "🧠 Dopamine receptors normalizing."
                ;;
            365)
                echo "🏅 ONE YEAR! You've completely transformed."
                echo "💖 Health risks dramatically reduced."
                ;;
        esac

        return 0
    else
        local days_left=$((target - current_streak))
        local day_num=$((current_streak + 1))
        echo "📍 Day $day_num"
        echo "🎯 Milestone: $target days"
        echo "📈 $days_left days to go"
        return 1
    fi
}

function record_slip() {
    local json=$(cat "$TRACKER_FILE")
    local current_streak=$(echo "$json" | jq -r '.current_streak')
    local longest_streak=$(echo "$json" | jq -r '.longest_streak')

    # Record the slip
    local slip_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    json=$(echo "$json" | jq --arg slip "$slip_date" \
        --argjson streak "$current_streak" \
        '.slips += [{"date": $slip, "streak": $streak}]')

    # Reset counter
    json=$(echo "$json" | jq '.start_date = null | .current_streak = 0')
    echo "$json" > "$TRACKER_FILE"

    echo "💔 Slip recorded."
    echo "📊 Previous streak: $current_streak days"
    echo "🏆 Best streak: $longest_streak days"
    echo ""
    echo "💪 This doesn't erase your progress. Every day sober counts."
    echo "🔄 Use '$0 start' to begin a new streak when ready."
}

function calculate_savings() {
    local drinks_per_day=${1:-5}
    local cost_per_drink=${2:-5}
    local days_sober=${3:-30}

    local total_drinks=$((drinks_per_day * days_sober))
    local money_saved=$((total_drinks * cost_per_drink))
    local hours_saved=$((days_sober * 2))  # Estimate 2 hours/day drinking/hungover

    echo "💰 Sobriety Savings Calculator"
    echo "================================"
    echo "🍺 Previous: $drinks_per_day drinks/day × \$$cost_per_drink"
    echo "📅 Days sober: $days_sober"
    echo ""
    echo "💵 Money saved: \$$money_saved"
    echo "⏰ Time reclaimed: $hours_saved hours"
    echo "🩺 Health gain: Priceless"
}

# Main
case "${1:-help}" in
    start)
        start_sobriety "${2:-0}"
        ;;
    status)
        show_status
        ;;
    milestone)
        if [ -z "${2:-}" ]; then
            echo "Error: Please specify milestone days"
            echo "Usage: $0 milestone [days]"
            exit 1
        fi
        check_milestone "$2"
        ;;
    slip)
        record_slip
        ;;
    savings)
        calculate_savings "${2:-5}" "${3:-5}" "${4:-30}"
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
