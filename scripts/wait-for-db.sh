#!/bin/bash

# Warten bis die DB erreichbar ist
until pg_isready -h db -p 5432 -U freqtrade; do
  echo "Waiting for Postgres ($1)..."
  sleep 2
done

# Danach normaler Freqtrade Start mit allen übergebenen Parametern
exec freqtrade "$@"
