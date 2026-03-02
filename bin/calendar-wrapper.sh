#!/bin/bash
# Google Calendar API wrapper using OAuth2 refresh token

set -e

CONFIG="/root/.config/gogcli/keyring/botforoleg.json"
CREDENTIALS="/root/.config/gogcli/credentials.json"
OWNER_CALENDAR="olegzakharchenko@gmail.com"

# Read config
REFRESH_TOKEN=$(jq -r '.refresh_token' "$CONFIG")
CLIENT_ID=$(jq -r '.client_id' "$CREDENTIALS")
CLIENT_SECRET=$(jq -r '.client_secret' "$CREDENTIALS")

# Get new access token
TOKEN_RESPONSE=$(curl -s -X POST https://oauth2.googleapis.com/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "refresh_token=$REFRESH_TOKEN" \
  -d "grant_type=refresh_token")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token')

# Update access token in config
EXPIRES_IN=$(echo "$TOKEN_RESPONSE" | jq -r '.expires_in // 3600')
EXPIRES_AT=$(($(date +%s) + EXPIRES_IN))

jq --arg tok "$ACCESS_TOKEN" --arg exp "$EXPIRES_AT" \
  '.access_token = $tok | .expires_at = ($exp | tonumber)' \
  "$CONFIG" > "${CONFIG}.tmp" && mv "${CONFIG}.tmp" "$CONFIG"

# Execute Calendar API call
case "$1" in
  list)
    # List events from owner's calendar
    TIME_MIN="${2:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"
    MAX_RESULTS="${3:-10}"

    curl -s "https://www.googleapis.com/calendar/v3/calendars/$OWNER_CALENDAR/events?timeMin=$TIME_MIN&maxResults=$MAX_RESULTS&orderBy=startTime&singleEvents=true" \
      -H "Authorization: Bearer $ACCESS_TOKEN" | jq '.items[] | {id: .id, summary: .summary, start: (.start.dateTime // .start.date)}'
    ;;
  create)
    # Create event: ./calendar-wrapper.sh create "Summary" "Description" "YYYY-MM-DDTHH:MM:SS+01:00" "Duration in minutes"
    SUMMARY="$2"
    DESCRIPTION="${3:-}"
    START_TIME="$4"
    DURATION="${5:-60}"

    if [ -z "$SUMMARY" ] || [ -z "$START_TIME" ]; then
      echo "❌ Usage: $0 create \"Summary\" \"Description\" \"YYYY-MM-DDTHH:MM:SS+01:00\" [duration_minutes]"
      exit 1
    fi

    # Calculate end time
    END_TIME=$(date -d "$START_TIME + $DURATION minutes" -u +%Y-%m-%dT%H:%M:%S%:z 2>/dev/null || date -d "$START_TIME + $DURATION minutes" +%Y-%m-%dT%H:%M:%S+01:00)

    EVENT_DATA=$(cat <<EOF
{
  "summary": "$SUMMARY",
  "description": "$DESCRIPTION",
  "start": {
    "dateTime": "$START_TIME",
    "timeZone": "Europe/Vienna"
  },
  "end": {
    "dateTime": "$END_TIME",
    "timeZone": "Europe/Vienna"
  }
}
EOF
)

    curl -s -X POST "https://www.googleapis.com/calendar/v3/calendars/$OWNER_CALENDAR/events" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$EVENT_DATA" | jq '{id: .id, summary: .summary, status: .status, link: .htmlLink}'
    ;;
  get)
    # Get event by ID
    EVENT_ID="$2"

    if [ -z "$EVENT_ID" ]; then
      echo "❌ Usage: $0 get <event_id>"
      exit 1
    fi

    curl -s "https://www.googleapis.com/calendar/v3/calendars/$OWNER_CALENDAR/events/$EVENT_ID" \
      -H "Authorization: Bearer $ACCESS_TOKEN" | jq '.'
    ;;
  *)
    echo "Usage: $0 {list|create|get} [args]"
    echo "  $0 list [time_min] [max_results]  - List upcoming events"
    echo "  $0 create \"Summary\" \"Desc\" \"Start\" [duration]  - Create event"
    echo "  $0 get <event_id>                    - Get event details"
    exit 1
    ;;
esac
