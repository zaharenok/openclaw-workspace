#!/bin/bash
# Check botforoleg@gmail.com for new emails from olegzakharchenko@gmail.com

set -e

CONFIG="/root/.config/gogcli/keyring/botforoleg.json"
CREDENTIALS="/root/.config/gogcli/credentials.json"
OWNER_EMAIL="olegzakharchenko@gmail.com"

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

# Get messages from owner
MESSAGES=$(curl -s "https://www.googleapis.com/gmail/v1/users/me/messages?alt=json&fields=messages(id,threadId),nextPageToken&q=from:$OWNER_EMAIL" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

# Check if messages field exists and has items
if echo "$MESSAGES" | jq -e '.messages' > /dev/null 2>&1; then
  COUNT=$(echo "$MESSAGES" | jq '.messages | length')

  if [ "$COUNT" -eq 0 ]; then
    # Silent - no messages
    exit 0
  fi

  echo "📧 Found $COUNT message(s) from $OWNER_EMAIL"
  echo "$MESSAGES" | jq -r '.messages[] | "\(.id) \(.threadId)"'
else
  # Silent - no messages
  exit 0
fi
