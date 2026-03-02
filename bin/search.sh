#!/bin/bash
# Simple web search via DuckDuckGo HTML (no API key needed)

QUERY="$1"
COUNT="${2:-3}"

if [ -z "$QUERY" ]; then
  echo "Usage: $0 <query> [count]"
  exit 1
fi

# URL encode query
ENCODED=$(echo "$QUERY" | sed 's/ /%20/g')

# Fetch DuckDuckGo HTML results
URL="https://html.duckduckgo.com/html/?q=${ENCODED}"

curl -s -A "Mozilla/5.0" "$URL" | \
  grep -oP '<a[^>]+class="result__a"[^>]*>\K[^<]+' | \
  head -n "$COUNT"
