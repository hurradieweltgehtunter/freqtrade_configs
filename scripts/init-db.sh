#!/bin/bash

set -e

# PostgreSQL-Zugangsdaten
PGUSER="freqtrade"
PGDATABASE="postgres"

# DB-Liste kommt aus ENV-Variable DATABASES (Komma getrennt)
IFS=',' read -r -a DB_LIST <<< "$DATABASES"

echo "Warte auf PostgreSQL..."
until pg_isready -U "$PGUSER" -d "$PGDATABASE"; do
  sleep 2
done

echo "PostgreSQL ist bereit. Überprüfe Datenbanken..."

for db in "${DB_LIST[@]}"; do
  if psql -U "$PGUSER" -d "$PGDATABASE" -tAc "SELECT 1 FROM pg_database WHERE datname='$db'" | grep -q 1; then
    echo "✅ Datenbank $db existiert bereits."
  else
    echo "➔ Erstelle Datenbank $db ..."
    psql -U "$PGUSER" -d "$PGDATABASE" -c "CREATE DATABASE $db OWNER $PGUSER;"
  fi
done

echo "✅ Alle Datenbanken sind bereit."
