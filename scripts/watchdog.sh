#!/bin/bash

INTERVAL="${WATCHDOG_INTERVAL:-60}"
CONTAINERS=("BinanceX5Spot" "BitgetX5Spot")

# Telegram-Konfig
TOKEN="${TELEGRAM_TOKEN}"
CHAT_ID="${TELEGRAM_CHAT_ID}"

send_telegram() {
  MESSAGE="$1"
  [[ -z "$TOKEN" || -z "$CHAT_ID" ]] && return
  curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
    -d chat_id="${CHAT_ID}" \
    -d text="$MESSAGE" \
    -d parse_mode="Markdown" > /dev/null
}

while true; do
  for CONTAINER in "${CONTAINERS[@]}"; do
    STATUS=$(docker inspect --format='{{.State.Status}}' "$CONTAINER" 2>/dev/null || echo "notfound")

    if [[ "$STATUS" != "running" ]]; then
      MSG="$(date) - ⚠️ *$CONTAINER* not running (Status: $STATUS). Restarting..."
      echo "$MSG"
      send_telegram "$MSG"
      docker restart "$CONTAINER"
    else
      echo "$(date) - $CONTAINER is running fine."
    fi
  done
  sleep "$INTERVAL"
done