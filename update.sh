#!/bin/bash
# Dieses Script aktualisiert Configs und Strategien und führt Reloads der laufenden Bots durch.

BASE_DIR="/home/holu/freqtrade"
CONFIG_REPO="$BASE_DIR/freqtrade_configs"
USER_DATA="$BASE_DIR/user_data"
NFI_DIR="$USER_DATA/strategies/NostalgiaForInfinity"

# Liste der Bot-Container
BOTS=("BinanceX5Spot" "BitgetX5Spot" "GateioX5Spot")

# ==== Logfile erstellen ====
if [ ! -d "$USER_DATA/logs" ]; then
    mkdir -p "$USER_DATA/logs"
fi

LOGFILE="$USER_DATA/logs/updates.log"
echo "===== Update gestartet am $(date) =====" >> "$LOGFILE"


# ==== freqtrade_configs Repo prüfen ====
# check if user_data/configs directory exists and create, if not
if [ ! -d "$USER_DATA/configs" ]; then
    echo "Erstelle $USER_DATA/configs..." >> "$LOGFILE"
    mkdir -p "$USER_DATA/configs"
else
    echo "$USER_DATA/configs existiert bereits." >> "$LOGFILE"
fi

if [ -d "$CONFIG_REPO" ]; then
    echo "Prüfe freqtrade_configs Repo..." >> "$LOGFILE"
    cd "$CONFIG_REPO"
    local_commit_before=$(git rev-parse HEAD)
    git fetch --all >> "$LOGFILE" 2>&1
    git reset --hard origin/main >> "$LOGFILE" 2>&1
    local_commit_after=$(git rev-parse HEAD)

    if [ "$local_commit_before" != "$local_commit_after" ]; then
        echo "Änderungen im freqtrade_configs Repo erkannt. Aktualisiere Configs..." >> "$LOGFILE"

        # Truncate configs directory
        if [ -d "$USER_DATA/configs" ]; then
            echo "Leere $USER_DATA/configs..." >> "$LOGFILE"
            rm -rf "$USER_DATA/configs/"*
        fi

        # Copy new configs
        if [ -d "$CONFIG_REPO/configs" ]; then
            echo "Kopiere neue Configs..." >> "$LOGFILE"
            cp -r "$CONFIG_REPO/configs/"* "$USER_DATA/configs/"
        else
            echo "FEHLER: $CONFIG_REPO/configs nicht gefunden!" >> "$LOGFILE"
        fi

        # Copy docker-compose.yml
        if [ -f "$CONFIG_REPO/docker-compose.yml" ]; then
            echo "Kopiere docker-compose.yml..." >> "$LOGFILE"
            cp "$CONFIG_REPO/docker-compose.yml" "$BASE_DIR/"
        else
            echo "FEHLER: docker-compose.yml nicht gefunden!" >> "$LOGFILE"
        fi

        # Copy Dockerfile.custom
        if [ -f "$CONFIG_REPO/Dockerfile.custom" ]; then
            echo "Kopiere Dockerfile.custom..." >> "$LOGFILE"
            cp "$CONFIG_REPO/Dockerfile.custom" "$BASE_DIR/"
        else
            echo "FEHLER: Dockerfile.custom nicht gefunden!" >> "$LOGFILE"
        fi

        # Copy Dockerfile.watchdog
        if [ -f "$CONFIG_REPO/Dockerfile.watchdog" ]; then
            echo "Kopiere Dockerfile.watchdog..." >> "$LOGFILE"
            cp "$CONFIG_REPO/Dockerfile.watchdog" "$BASE_DIR/"
        else
            echo "FEHLER: Dockerfile.watchdog nicht gefunden!" >> "$LOGFILE"
        fi

        # Make all scripts executable in $CONFIG_REPO/scripts
        if [ -d "$CONFIG_REPO/scripts" ]; then
            echo "Mache alle Skripte in $CONFIG_REPO/scripts ausführbar..." >> "$LOGFILE"
            chmod +x "$CONFIG_REPO/scripts/"*
        else
            echo "FEHLER: $CONFIG_REPO/scripts nicht gefunden!" >> "$LOGFILE"
        fi
    else
        echo "Keine Änderungen im freqtrade_configs Repo. Überspringe Config-Update." >> "$LOGFILE"
    fi
else
    echo "FEHLER: freqtrade_configs Repo nicht gefunden!" >> "$LOGFILE"
fi

# ==== NostalgiaForInfinity Repo prüfen ====
if [ -d "$NFI_DIR" ]; then
    echo "Prüfe NostalgiaForInfinity Repo..." >> "$LOGFILE"
    cd "$NFI_DIR"
    local_nfi_commit_before=$(git rev-parse HEAD)
    git pull >> "$LOGFILE" 2>&1
    local_nfi_commit_after=$(git rev-parse HEAD)

    if [ "$local_nfi_commit_before" != "$local_nfi_commit_after" ]; then
        echo "Änderungen im NFI Repo erkannt. Aktualisiere Strategien..." >> "$LOGFILE"
        
        if [ -f "$NFI_DIR/NostalgiaForInfinityX5.py" ]; then
            echo "Kopiere NostalgiaForInfinityX5.py..." >> "$LOGFILE"
            cp "$NFI_DIR/NostalgiaForInfinityX5.py" "$USER_DATA/strategies/NostalgiaForInfinityX5.py"
        else
            echo "WARNUNG: NostalgiaForInfinityX5.py nicht gefunden!" >> "$LOGFILE"
        fi
        
        if [ -f "$NFI_DIR/NostalgiaForInfinityX6.py" ]; then
            echo "Kopiere NostalgiaForInfinityX6.py..." >> "$LOGFILE"
            cp "$NFI_DIR/NostalgiaForInfinityX6.py" "$USER_DATA/strategies/NostalgiaForInfinityX6.py"
        else
            echo "WARNUNG: NostalgiaForInfinityX6.py nicht gefunden!" >> "$LOGFILE"
        fi
    else
        echo "Keine Änderungen im NFI Repo. Überspringe Strategie-Update." >> "$LOGFILE"
    fi
else
    echo "FEHLER: NostalgiaForInfinity Repo nicht gefunden!" >> "$LOGFILE"
fi

echo "===== Update abgeschlossen am $(date) =====" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# ==== Freqtrade Bots neu laden ====
for BOT in "${BOTS[@]}"; do
    echo "♻️ Starte Container $BOT neu, um Config und Strategie zu laden..." >> "$LOGFILE"
    
    curl -u $BINANCEX5SPOT_API_SERVER__USERNAME:$BINANCEX5SPOT_API_SERVER__PASSWORD http://localhost:8081/api/v1/reload_config -X POST

    # if docker restart "$BOT" >> "$LOGFILE" 2>&1; then
    #     echo "✅ Container $BOT erfolgreich neu gestartet." >> "$LOGFILE"
    # else
    #     echo "❌ Fehler beim Neustart des Containers $BOT." >> "$LOGFILE"
    # fi
done

# ==== update.sh erneut ausführbar machen (falls durch Git überschrieben) ====
chmod +x "$CONFIG_REPO/update.sh"