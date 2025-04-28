#!/bin/bash
# Removes a subbdomain from nginx and deletes the SSL certificate
# sudo ./remove-subdomain.sh binance-x5-spot
# Prüfen ob 1 Parameter übergeben wurde
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <subdomain>"
    exit 1
fi

# Übergabeparameter
SUBDOMAIN=$1
DOMAIN="florianlenz.com"
FULL_DOMAIN="$SUBDOMAIN.$DOMAIN"

# Pfade
CONFIG_FILE="/etc/nginx/sites-available/$SUBDOMAIN"
SYMLINK_FILE="/etc/nginx/sites-enabled/$SUBDOMAIN"

# 1. Symlink entfernen, falls vorhanden
if [ -L "$SYMLINK_FILE" ]; then
    echo "🗑 Entferne Symlink für $FULL_DOMAIN..."
    sudo rm "$SYMLINK_FILE"
else
    echo "ℹ️ Kein Symlink für $FULL_DOMAIN gefunden."
fi

# 2. Config-Datei entfernen, falls vorhanden
if [ -f "$CONFIG_FILE" ]; then
    echo "🗑 Entferne Config-Datei für $FULL_DOMAIN..."
    sudo rm "$CONFIG_FILE"
else
    echo "ℹ️ Keine Config-Datei für $FULL_DOMAIN gefunden."
fi

# 3. NGINX neu laden
echo "🔄 Lade NGINX neu..."
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✅ NGINX neu geladen."
else
    echo "❌ Fehler in NGINX-Config. Bitte manuell prüfen!"
    exit 1
fi

# 4. Zertifikat löschen
if sudo certbot certificates | grep -q "$FULL_DOMAIN"; then
    echo "🗑 Lösche SSL-Zertifikat für $FULL_DOMAIN..."
    sudo certbot delete --cert-name "$FULL_DOMAIN"
else
    echo "ℹ️ Kein SSL-Zertifikat für $FULL_DOMAIN gefunden."
fi

echo "🎯 Entfernung von $FULL_DOMAIN abgeschlossen!"