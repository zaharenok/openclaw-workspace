#!/bin/bash
# Gmail API wrapper using OAuth2 refresh token

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

# Execute Gmail API call
case "$1" in
  list)
    QUERY="${2:-.}"
    LIMIT="${3:-10}"
    curl -s "https://www.googleapis.com/gmail/v1/users/me/messages?alt=json&fields=messages(id,threadId),nextPageToken&maxResults=$LIMIT&q=$(echo "$QUERY" | sed 's/ /%20/g')" \
      -H "Authorization: Bearer $ACCESS_TOKEN" | jq '.'
    ;;
  get)
    MSG_ID="$2"
    curl -s "https://www.googleapis.com/gmail/v1/users/me/messages/$MSG_ID?format=full&alt=json" \
      -H "Authorization: Bearer $ACCESS_TOKEN" | jq '.'
    ;;
  *)
    echo "Usage: $0 {list|get} [args]"
    echo "  $0 list [query] [limit]  - List messages"
    echo "  $0 get <message_id>      - Get message"
    exit 1
    ;;
esac
