#!/bin/bash
set -e

# Nutze direkt die Umgebungsvariablen aus der docker-compose.yml
PGUSER="${POSTGRES_USER}"
PGPASSWORD="${POSTGRES_PASSWORD}"
PGDATABASE="postgres"

# Optional: Verbindung über localhost explizit setzen
PGHOST="localhost"
PGPORT="5432"

# Exportieren, damit psql sie benutzt
export PGUSER PGPASSWORD PGHOST PGPORT

# DB-Liste aus ENV-Variable DATABASES (Komma getrennt)
IFS=',' read -r -a DB_LIST <<< "$DATABASES"

echo "Warte auf PostgreSQL Server $PGHOST:$PGPORT..."
until pg_isready -U "$PGUSER" -h "$PGHOST" -p "$PGPORT" -d "$PGDATABASE"; do
  sleep 2
done

echo "PostgreSQL ist bereit. Überprüfe Datenbanken..."

for db in "${DB_LIST[@]}"; do
  if psql -d "$PGDATABASE" -tAc "SELECT 1 FROM pg_database WHERE datname='$db'" | grep -q 1; then
    echo "✅ Datenbank $db existiert bereits."
  else
    echo "➔ Erstelle Datenbank $db ..."
    createdb -O "$PGUSER" "$db"
  fi
done

echo "✅ Alle gewünschten Datenbanken sind vorhanden."