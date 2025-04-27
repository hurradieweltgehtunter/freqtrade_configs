#!/bin/bash

# Standard-Intervall in Sekunden, falls keine ENV gesetzt
INTERVAL="${WATCHDOG_INTERVAL:-60}"

CONTAINERS=("BinanceX5Spot" "BitgetX5Spot")

while true; do
  for CONTAINER in "${CONTAINERS[@]}"; do
    STATUS=$(docker inspect --format='{{.State.Status}}' "$CONTAINER" 2>/dev/null || echo "notfound")

    if [[ "$STATUS" != "running" ]]; then
      echo "$(date) - $CONTAINER not running (Status: $STATUS). Restarting..."
      docker restart "$CONTAINER"
    else
      echo "$(date) - $CONTAINER is running fine."
    fi
  done
  sleep "$INTERVAL"
done