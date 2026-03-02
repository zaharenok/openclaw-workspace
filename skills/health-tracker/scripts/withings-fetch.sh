#!/bin/bash
# Fetch health data from Withings API
# Usage: ./withings-fetch.sh [weight|sleep|activity|all]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../withings-creds.sh"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config not found. Run ./withings-auth.sh first"
  exit 1
fi

source "$CONFIG_FILE"

# Check if access token exists
if [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Access token not found. Run ./withings-auth.sh"
  exit 1
fi

# Check if token needs refresh
NOW=$(date +%s)
if [ $NOW -gt ${TOKEN_EXPIRES:-0} ]; then
  echo "🔄 Access token expired. Refreshing..."
  
  REFRESH_RESPONSE=$(curl -s -X POST \
    "https://wbsapi.withings.net/v2/oauth2" \
    -d "action=requesttoken" \
    -d "client_id=$CLIENT_ID" \
    -d "client_secret=$CLIENT_SECRET" \
    -d "grant_type=refresh_token" \
    -d "refresh_token=$REFRESH_TOKEN")
  
  NEW_ACCESS_TOKEN=$(echo "$REFRESH_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('body', {}).get('access_token', ''))")
  NEW_REFRESH_TOKEN=$(echo "$REFRESH_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('body', {}).get('refresh_token', ''))")
  
  if [ -z "$NEW_ACCESS_TOKEN" ]; then
    echo "❌ Failed to refresh token. Run ./withings-auth.sh"
    exit 1
  fi
  
  # Update tokens in config
  sed -i "s/^ACCESS_TOKEN=.*/ACCESS_TOKEN=\"$NEW_ACCESS_TOKEN\"/" "$CONFIG_FILE"
  sed -i "s/^REFRESH_TOKEN=.*/REFRESH_TOKEN=\"$NEW_REFRESH_TOKEN\"/" "$CONFIG_FILE"
  sed -i "s/^TOKEN_EXPIRES=.*/TOKEN_EXPIRES=$(($NOW + 10800))/" "$CONFIG_FILE"
  
  source "$CONFIG_FILE"
  echo "✅ Token refreshed"
fi

DATA_TYPE="${1:-all}"
OUTPUT_DIR="$SCRIPT_DIR/../data"
mkdir -p "$OUTPUT_DIR"

# Fetch weight data
fetch_weight() {
  echo "📊 Fetching weight data..."
  
  RESPONSE=$(curl -s -X POST \
    "https://wbsapi.withings.net/measure" \
    -d "action=getmeas" \
    -d "access_token=$ACCESS_TOKEN" \
    -d "meastypes=1" \
    -d "category=1")
  
  echo "$RESPONSE" | python3 -m json.tool > "$OUTPUT_DIR/weight-raw.json"
  
  # Parse to CSV
  echo "$RESPONSE" | python3 <<'PYTHON'
import sys, json
data = json.load(sys.stdin)
if data['status'] == 0:
    measures = data.get('body', {}).get('measuregrps', [])
    print("date,weight_kg,fat_percent,muscle_mass,hydration")
    for m in measures:
        date = m['date']
        weight = None
        fat = None
        muscle = None
        hydration = None
        
        for measure in m['measures']:
            if measure['type'] == 1:  # Weight
                weight = round(measure['value'] * 10**measure['unit'], 2)
            elif measure['type'] == 8:  # Fat ratio
                fat = round(measure['value'] * 10**measure['unit'], 2)
            elif measure['type'] == 10:  # Muscle mass
                muscle = round(measure['value'] * 10**measure['unit'], 2)
            elif measure['type'] == 11:  # Hydration
                hydration = round(measure['value'] * 10**measure['unit'], 2)
        
        print(f"{date},{weight},{fat},{muscle},{hydration}")
PYTHON
}

# Fetch sleep data
fetch_sleep() {
  echo "😴 Fetching sleep data..."
  
  RESPONSE=$(curl -s -X GET \
    "https://wbsapi.withings.net/v2/sleep?action=getsummary&access_token=$ACCESS_TOKEN&startdate=$(( $(date +%s) - 7776000 ))&enddate=$(date +%s)")
  
  echo "$RESPONSE" | python3 -m json.tool > "$OUTPUT_DIR/sleep-raw.json"
  
  # Parse to CSV
  echo "$RESPONSE" | python3 <<'PYTHON'
import sys, json
data = json.load(sys.stdin)
if data['status'] == 0:
    series = data.get('body', {}).get('series', [])
    print("date,bedtime,wake_time,duration_sec,deep_sleep,light_sleep,rem_sleep,efficiency")
    for s in series:
        date = s.get('startdate', '')
        bedtime = s.get('starttime', 0)
        wake = s.get('endtime', 0)
        duration = s.get('duration', 0)
        deep = s.get('data', {}).get('deep_sleep_duration', 0)
        light = s.get('data', {}).get('light_sleep_duration', 0)
        rem = s.get('data', {}).get('rem_sleep_duration', 0)
        eff = s.get('data', {}).get('sleep_efficiency', 0)
        
        print(f"{date},{bedtime},{wake},{duration},{deep},{light},{rem},{eff}")
PYTHON
}

# Fetch activity data
fetch_activity() {
  echo "🏃 Fetching activity data..."
  
  RESPONSE=$(curl -s -X GET \
    "https://wbsapi.withings.net/v2/activity?action=getactivity&access_token=$ACCESS_TOKEN&startdate=$(( $(date +%s) - 604800 ))&enddate=$(date +%s)&data_fields=steps,distance,calories,active,soft")
  
  echo "$RESPONSE" | python3 -m json.tool > "$OUTPUT_DIR/activity-raw.json"
}

# Main
case "$DATA_TYPE" in
  weight)
    fetch_weight
    ;;
  sleep)
    fetch_sleep
    ;;
  activity)
    fetch_activity
    ;;
  all)
    fetch_weight
    fetch_sleep
    fetch_activity
    ;;
  *)
    echo "Usage: $0 [weight|sleep|activity|all]"
    exit 1
    ;;
esac

echo ""
echo "✅ Data saved to $OUTPUT_DIR/"
echo "Next: Run ./analyze-health.py to visualize"
