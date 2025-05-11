# freqtrade_configs

## Setup this repo
/update contains the update mechanism written in python. To enable it:
```
source .venv/bin/activate
```

```
pip install -r requirements.txt
```

cd update
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt


## Server config

curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

### UFW Firewall
To                         Action      From
--                         ------      ----
2222                       ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
2222 (v6)                  ALLOW       Anywhere (v6)
443/tcp (v6)               ALLOW       Anywhere (v6)
80/tcp (v6)                ALLOW       Anywhere (v6)

### Fail2Ban

Ist installiert
```
sudo fail2ban-client status
sudo fail2ban-client status sshd
sudo tail -f /var/log/fail2ban.log
```

### CLI
1. Oh My Zsh installieren
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

2. Powerlevel10k installieren

```
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

3. Theme auf Powerlevel10k umstellen

Öffne die .zshrc Datei:
```
nano ~/.zshrc
```

4. Suche die Zeile:
```
ZSH_THEME="robbyrussell"
```
Ändere auf
```
ZSH_THEME="powerlevel10k/powerlevel10k"
```

Starte Zsh neu:
```
exec zsh
```

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

### Postgres-Datenbank anlegen

Trage die neue DB freqtrade_kraken_x5_spot_db in der DATABASES-Umgebungsvariable deines Postgres-Services in docker-compose.yml ein:

Beispiel:

```
DATABASES: freqtrade_binance_x5_spot_db,freqtrade_bitget_x5_spot_db,freqtrade_gateio_x5_spot_db,**freqtrade_kraken_x5_spot_db**
```

Beim nächsten Start erstellt das init-db.sh Script die neue Datenbank automatisch.


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

#### Neuen Telegram bot erstellen
• Neuen Bot erstellen: `/newbot`
• Name vergeben: `<exchange><strategy><trading_mode>` z.B.: `BitgetX6Spot`
• Username vergeben: `<exxchange>_<strategy>_trading_mode>_bot` z.B.: `bitget_x6_spot_bot`
• Access token in .ENV Datei speichern

#### .ENV erweitern
Erweitere die .env Datei auf dem Server um die benötigten env vars.

• Generiere einen usernamen auf auf https://it-tools.tech/token-generator (Länge 32)
• Generiere ein Passwort in 1Password (Gleich darin speichern)
• Generiere einen jwt_secret_key auf https://jwtsecret.com/generate
• Generaiere einen ws_token auf https://it-tools.tech/token-generator
• Telegram token aus Bot creation eintragen
• Chat_ID eintragen. s.h. andere env vars für PN

#### CORS in Hauptbbot (UI) setzen

Erweitere die CORS settings in der freqtrade config des Bots, der die UI stellt, um die neue Subdomain. Dieser muss immer alle Subdomains enthalten.

### Subdomain bei All-Inkl einrichten

•	Logge dich bei All-Inkl ein.
•	Gehe auf Tools -> DNS-Einstellungen
•	florinalenz.com auswählen
•	Subdomain anlegen, z.b.: `kraken-x5-spot`
•	Ziel (A-Record): Server-IP

### Subdomain auf dem Server einrichten

Script setup-subdomain.sh:

```
sudo freqtrade_configs/scripts/setup-subdomain.sh <subdomain> <port>
```

Das Skript:
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

UND

```
freqtrade_configs/update/config.py
```

neuen Bot in BOTS eintragen

### Docker Compose neu starten

Jetzt bringst du alles ans Laufen:

```
sudo docker-compose up -d
```

✅ Dadurch werden:
• Neuer Bot gestartet
• Nginx neu konfiguriert
• Subdomain erreichbar
