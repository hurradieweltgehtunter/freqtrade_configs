#!/bin/bash

LOGFILE="/home/holu/freqtrade/update_configs.log"
echo "===== Update gestartet am $(date) =====" >> "$LOGFILE"

BASE_DIR="/home/holu/freqtrade"
CONFIG_REPO="$BASE_DIR/freqtrade_configs"
USER_DATA="$BASE_DIR/user_data"
NFI_DIR="$USER_DATA/strategies/NostalgiaForInfinity"

# ==== freqtrade_configs Repo prüfen ====
if [ -d "$CONFIG_REPO" ]; then
    echo "Prüfe freqtrade_configs Repo..." >> "$LOGFILE"
    cd "$CONFIG_REPO"
    local_commit_before=$(git rev-parse HEAD)
    git pull >> "$LOGFILE" 2>&1
    local_commit_after=$(git rev-parse HEAD)

    if [ "$local_commit_before" != "$local_commit_after" ]; then
        echo "Änderungen im freqtrade_configs Repo erkannt. Aktualisiere Configs..." >> "$LOGFILE"
        
        if [ -d "$USER_DATA/configs" ]; then
            echo "Leere $USER_DATA/configs..." >> "$LOGFILE"
            rm -rf "$USER_DATA/configs"
        fi

        if [ -d "$CONFIG_REPO/configs" ]; then
            echo "Kopiere neue Configs..." >> "$LOGFILE"
            cp -r "$CONFIG_REPO/configs" "$USER_DATA/"
        else
            echo "FEHLER: $CONFIG_REPO/configs nicht gefunden!" >> "$LOGFILE"
        fi

        if [ -f "$CONFIG_REPO/docker-compose.yml" ]; then
            echo "Kopiere docker-compose.yml..." >> "$LOGFILE"
            cp "$CONFIG_REPO/docker-compose.yml" "$BASE_DIR/"
        else
            echo "FEHLER: docker-compose.yml nicht gefunden!" >> "$LOGFILE"
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