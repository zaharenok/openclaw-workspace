#!/bin/bash
# Monitor Pete Steinberger's Newsletter
# Checks for new emails from peter@steipete.me and summarizes content

set -e

CONFIG="/root/.config/gogcli/keyring/botforoleg.json"
CREDENTIALS="/root/.config/gogcli/credentials.json"
OWNER_EMAIL="olegzakharchenko@gmail.com"
PETE_EMAIL="peter@steipete.me"

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

# Get messages from Pete
MESSAGES=$(curl -s "https://www.googleapis.com/gmail/v1/users/me/messages?alt=json&q=from:$PETE_EMAIL" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

# Check if messages field exists
if echo "$MESSAGES" | jq -e '.messages' > /dev/null 2>&1; then
    COUNT=$(echo "$MESSAGES" | jq '.messages | length')

    if [ "$COUNT" -eq 0 ]; then
        # Silent - no messages
        exit 0
    fi

    echo "📰 **Pete Steinberger Newsletter Update**"
    echo ""
    
    # Process each message
    echo "$MESSAGES" | jq -r '.messages[] | .id' | while read MESSAGE_ID; do
        # Get message details
        MSG=$(curl -s "https://www.googleapis.com/gmail/v1/users/me/messages/$MESSAGE_ID?format=full&metadataHeaders=From,Subject,Date" \
          -H "Authorization: Bearer $ACCESS_TOKEN")
        
        # Extract headers
        SUBJECT=$(echo "$MSG" | jq -r '.payload.headers[] | select(.name == "Subject") | .value' | sed 's/What'"'"'s new with Pete: //')
        DATE=$(echo "$MSG" | jq -r '.payload.headers[] | select(.name == "Date") | .value')
        
        # Extract body
        BODY=$(echo "$MSG" | python3 -c "
import sys, json, base64, email, re
msg = json.load(sys.stdin)
payload = msg['payload']

def get_part(parts):
    for part in parts:
        if part['mimeType'] == 'text/plain':
            data = part['body'].get('data', '')
            if data:
                return base64.urlsafe_b64decode(data).decode('utf-8', errors='ignore')
        if 'parts' in part:
            result = get_part(part['parts'])
            if result:
                return result
    return ''

if 'parts' in payload:
    body = get_part(payload['parts'])
    print(body)
elif 'body' in payload and 'data' in payload['body']:
    data = payload['body']['data']
    text = base64.urlsafe_b64decode(data).decode('utf-8', errors='ignore')
    print(text)
" 2>/dev/null)

        # Clean up body (remove HTML, links, etc)
        CLEAN_BODY=$(echo "$BODY" | sed 's/<[^>]*>//g' | sed 's/\[.*\]//g' | tr -s '\n' | head -20)
        
        echo "📌 **$SUBJECT**"
        echo "📅 $DATE"
        echo ""
        echo "$CLEAN_BODY"
        echo ""
        echo "---"
        echo ""
    done
    
    echo ""
    echo "💾 **Note:** Original emails preserved in botforoleg@gmail.com"
    echo "🗑️  To delete, mark as read in Gmail or move to trash"
else
    exit 0
fi
