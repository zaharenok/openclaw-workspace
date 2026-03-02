#!/bin/bash
# Google Sheets API wrapper using OAuth2 refresh token

set -e

CONFIG="/root/.config/gogcli/keyring/botforoleg.json"
CREDENTIALS="/root/.config/gogcli/credentials.json"

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

# Execute Sheets API call
case "$1" in
  create)
    # Create spreadsheet: ./sheets-wrapper.sh create "Title"
    TITLE="$2"

    if [ -z "$TITLE" ]; then
      echo "❌ Usage: $0 create \"Title\""
      exit 1
    fi

    CREATE_DATA=$(cat <<EOF
{
  "properties": {
    "title": "$TITLE"
  }
}
EOF
)

    curl -s -X POST "https://sheets.googleapis.com/v4/spreadsheets" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$CREATE_DATA" | jq '{spreadsheetId: .spreadsheetId, title: .properties.title, url: "https://docs.google.com/spreadsheets/d/\(.spreadsheetId)"}'
    ;;
  read)
    # Read data: ./sheets-wrapper.sh read <spreadsheet_id> [range]
    SPREADSHEET_ID="$2"
    RANGE="${3:-Sheet1!A1:Z100}"

    if [ -z "$SPREADSHEET_ID" ]; then
      echo "❌ Usage: $0 read <spreadsheet_id> [range]"
      exit 1
    fi

    curl -s "https://sheets.googleapis.com/v4/spreadsheets/$SPREADSHEET_ID/values/$RANGE" \
      -H "Authorization: Bearer $ACCESS_TOKEN" | jq '.values // []'
    ;;
  write)
    # Write data: ./sheets-wrapper.sh write <spreadsheet_id> <range> "data1,data2,data3"
    SPREADSHEET_ID="$2"
    RANGE="$3"
    DATA="$4"

    if [ -z "$SPREADSHEET_ID" ] || [ -z "$RANGE" ] || [ -z "$DATA" ]; then
      echo "❌ Usage: $0 write <spreadsheet_id> <range> \"data1,data2,data3\""
      exit 1
    fi

    # Parse CSV data to JSON array
    IFS=',' read -ra VALUES <<< "$DATA"
    VALUES_JSON=$(printf '%s\n' "${VALUES[@]}" | jq -R . | jq -s .)

    UPDATE_DATA=$(cat <<EOF
{
  "values": [[$VALUES_JSON]]
}
EOF
)

    curl -s -X PUT "https://sheets.googleapis.com/v4/spreadsheets/$SPREADSHEET_ID/values/$RANGE?valueInputOption=USER_ENTERED" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$UPDATE_DATA" | jq '{updatedRange: .updates.updatedRange, updatedRows: .updates.updatedRows}'
    ;;
  append)
    # Append rows: ./sheets-wrapper.sh append <spreadsheet_id> <range> "data1,data2,data3"
    SPREADSHEET_ID="$2"
    RANGE="$3"
    DATA="$4"

    if [ -z "$SPREADSHEET_ID" ] || [ -z "$RANGE" ] || [ -z "$DATA" ]; then
      echo "❌ Usage: $0 append <spreadsheet_id> <range> \"data1,data2,data3\""
      exit 1
    fi

    # Parse CSV data to JSON array
    IFS=',' read -ra VALUES <<< "$DATA"
    VALUES_JSON=$(printf '%s\n' "${VALUES[@]}" | jq -R . | jq -s .)

    UPDATE_DATA=$(cat <<EOF
{
  "values": [[$VALUES_JSON]]
}
EOF
)

    curl -s -X POST "https://sheets.googleapis.com/v4/spreadsheets/$SPREADSHEET_ID/values/$RANGE:append?valueInputOption=USER_ENTERED" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$UPDATE_DATA" | jq '{updatedRange: .updates.updatedRange, updatedRows: .updates.updatedRows}'
    ;;
  *)
    echo "Usage: $0 {create|read|write|append} [args]"
    echo "  $0 create \"Title\"                          - Create spreadsheet"
    echo "  $0 read <spreadsheet_id> [range]             - Read data"
    echo "  $0 write <spreadsheet_id> <range> \"data\"   - Write cell"
    echo "  $0 append <spreadsheet_id> <range> \"data\"  - Append row"
    exit 1
    ;;
esac
