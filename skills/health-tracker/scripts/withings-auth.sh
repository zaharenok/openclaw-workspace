#!/bin/bash
# Withings API OAuth 2.0 Authorization
# Usage: ./withings-auth.sh

set -e

CONFIG_FILE="/root/.openclaw/workspace/skills/health-tracker/withings-creds.sh"

echo "🔐 Withings API Authorization"
echo ""

# Load existing config or create new
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
  echo "Found existing credentials:"
  echo "  Client ID: ${CLIENT_ID:0:8}..."
  echo "  Customer ID: ${CUSTOMER_ID:0:8}..."
  echo ""
  read -p "Use existing credentials? (y/n): " USE_EXISTING
  if [ "$USE_EXISTING" = "y" ]; then
    echo "✅ Using existing config"
  else
    rm "$CONFIG_FILE"
  fi
fi

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Step 1: Register Withings app"
  echo "  1. Go to: https://account.withings.com/partner/add"
  echo "  2. Fill in app details"
  echo "  3. Set Callback URL: http://localhost:8080/withings/callback"
  echo "  4. Note your Client ID and Customer Key"
  echo ""
  read -p "Enter Client ID: " CLIENT_ID
  read -p "Enter Consumer Secret (Customer Key): " CLIENT_SECRET
  read -p "Enter Customer ID: " CUSTOMER_ID
  
  # Save config
  cat > "$CONFIG_FILE" <<EOF
# Withings API Credentials
CLIENT_ID="$CLIENT_ID"
CLIENT_SECRET="$CLIENT_SECRET"
CUSTOMER_ID="$CUSTOMER_ID"
REDIRECT_URI="http://localhost:8080/withings/callback"
EOF
  
  chmod 600 "$CONFIG_FILE"
  echo "✅ Credentials saved"
fi

# Step 2: Build authorization URL
source "$CONFIG_FILE"

AUTH_URL="https://account.withings.com/oauth2_user/authorize2?"
AUTH_URL+="response_type=code&"
AUTH_URL+="client_id=$CLIENT_ID&"
AUTH_URL+="state=$RANDOM&"
AUTH_URL+="scope=user.info,user.metrics,user.activity&"
AUTH_URL+="redirect_uri=$(echo "$REDIRECT_URI" | sed 's/:/%3A/g' | sed 's/\//%2F/g')&"
AUTH_URL+="token_type=code"

echo ""
echo "Step 2: Authorization"
echo "Open this URL in your browser:"
echo ""
echo "$AUTH_URL"
echo ""
echo "After authorization, you'll be redirected to:"
echo "  $REDIRECT_URI?code=XXXXX&state=XXXX"
echo ""
read -p "Paste the full redirect URL here: " REDIRECT_URL

# Extract authorization code
AUTH_CODE=$(echo "$REDIRECT_URL" | grep -oP 'code=\K[^&]*' || true)

if [ -z "$AUTH_CODE" ]; then
  echo "❌ Failed to extract authorization code"
  exit 1
fi

echo "✅ Authorization code received"

# Step 3: Exchange for access token
echo ""
echo "Step 3: Getting access token..."

TOKEN_RESPONSE=$(curl -s -X POST \
  "https://wbsapi.withings.net/v2/oauth2" \
  -d "action=requesttoken" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "grant_type=authorization_code" \
  -d "code=$AUTH_CODE" \
  -d "redirect_uri=$REDIRECT_URI")

echo "Token response:"
echo "$TOKEN_RESPONSE" | python3 -m json.tool

# Extract tokens
ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('body', {}).get('access_token', ''))")
REFRESH_TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('body', {}).get('refresh_token', ''))")
USER_ID=$(echo "$TOKEN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('body', {}).get('userid', ''))")

if [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Failed to get access token"
  exit 1
fi

# Save tokens
cat >> "$CONFIG_FILE" <<EOF

# OAuth Tokens (auto-refreshed)
ACCESS_TOKEN="$ACCESS_TOKEN"
REFRESH_TOKEN="$REFRESH_TOKEN"
USER_ID="$USER_ID"
TOKEN_EXPIRES=$(($(date +%s) + 10800))  # 3 hours
EOF

echo ""
echo "✅ Authorization complete!"
echo "  Access Token: ${ACCESS_TOKEN:0:16}..."
echo "  Refresh Token: ${REFRESH_TOKEN:0:16}..."
echo "  User ID: $USER_ID"
echo ""
echo "Next: Run ./withings-fetch.sh to get data"
