# freqtrade_configs

## Add new bot

### Docker-Compose erweitern

    •	Öffne deine docker-compose.yml
    •	Füge für den neuen Bot einen neuen Service hinzu (ähnlich wie die bestehenden).

Beispiel für neuen Bot “KrakenX5Spot”:

```
    KrakenX5Spot:
        build:
            context: .
            dockerfile: Dockerfile.custom
        image: freqtradeorg/freqtrade:stable
        container_name: KrakenX5Spot
        restart: always
        volumes:
            - ./user_data:/freqtrade/user_data
            - /etc/localtime:/etc/localtime:ro
        env_file:
            - .env
        environment:
            - PYTHONUNBUFFERED=1
        ports:
            - '127.0.0.1:8084:8080'   # Neuer freier Port!
        networks:
            - freqtrade-net
        depends_on:
            - db
        command: >
            trade
            --logfile /freqtrade/user_data/logs/KrakenX5Spot.log
            --db-url postgresql+psycopg2://freqtrade:fr3qtrade@db:5432/freqtrade_kraken_x5_spot_db
            --config /freqtrade/user_data/configs/KrakenX5Spot.json
            --strategy NostalgiaForInfinityX5
```

Wichtig:

-   Neuen Port zuweisen: z.B. 8084.
-   Neue Datenbank angeben: z.B. freqtrade_kraken_x5_spot_db.

### Neue Freqtrade Config-Datei erstellen

Erstelle im Verzeichnis user_data/configs/ eine neue Datei, z.B. KrakenX5Spot.json.

Wichtige Einträge darin:

```
{
    "api_server": {
        "enabled": true,
        "listen_ip_address": "0.0.0.0",
        "listen_port": 8080,
        "CORS_origins": ["binance-x5-spot.florianlenz.com"],
        "username": "freqtrader",
        "password": "deinPasswort"
    },
    "db_url": "postgresql+psycopg2://freqtrade:fr3qtrade@db:5432/freqtrade_kraken_x5_spot_db",
    "exchange": {
        "name": "kraken",
        ...
    }
}
```

Hinweis:
• listen_port immer 8080 belassen.
• Die Ports unterscheiden sich nur auf Docker-Compose-Ebene (127.0.0.1:8084:8080).

#### CORS in Hauptbbot (UI) setzen

Erweitere die CORS settings in der freqtrade config des Bots, der die UI stellt, um die neue Subdomain. Dieser muss immer alle Subdomains enthalten.

### Postgres-Datenbank anlegen

    •	Trage die neue DB freqtrade_kraken_x5_spot_db in der DATABASES-Umgebungsvariable deines Postgres-Services in docker-compose.yml ein:

Beispiel:

```
DATABASES: freqtrade_binance_x5_spot_db,freqtrade_bitget_x5_spot_db,freqtrade_gateio_x5_spot_db,freqtrade_kraken_x5_spot_db
```

Beim nächsten Start erstellt das init-db.sh Script die neue Datenbank automatisch.

⸻

### Subdomain bei All-Inkl einrichten

    •	Logge dich bei All-Inkl ein.
    •	Gehe auf Domainverwaltung → Subdomain hinzufügen.
    •	Beispiel:
    •	Subdomain: kraken-x5-spot
    •	Ziel (A-Record): 65.21.61.51 (deine Server-IP)

✅ Wichtig: Speichern und DNS-Update abwarten (ca. 5–30 Minuten).

⸻

### Subdomain auf dem Server einrichten

    •	Nutze dein Script setup-subdomain.sh:

```
sudo freqtrade_configs/scripts/setup-subdomain.sh kraken-x5-spot 8084
```

➡️ Das Skript:
• Erzeugt die Nginx-Config.
• Fordert automatisch das SSL-Zertifikat an.
• Richtet HTTPS-Weiterleitung korrekt ein.
• Lädt Nginx neu.

### Neuen Bot im update script eintragen
```
freqtrade_configs/update.sh

BOTS=("BinanceX5Spot" "BitgetX5Spot" "GateioX5Spot")
```
Die Liste der Bots erweitern um neuen Bot.


### Docker Compose neu starten

Jetzt bringst du alles ans Laufen:

```
sudo docker-compose up -d
```

✅ Dadurch werden:
• Neuer Bot gestartet
• Nginx neu konfiguriert
• Subdomain erreichbar
