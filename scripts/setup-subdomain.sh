#!/bin/bash

# Prüfen ob 2 Parameter übergeben wurden
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <subdomain> <port>"
    exit 1
fi

# Übergabeparameter
SUBDOMAIN=$1
PORT=$2
DOMAIN="florianlenz.com"
FULL_DOMAIN="$SUBDOMAIN.$DOMAIN"

# Pfade
CONFIG_FILE="/etc/nginx/sites-available/$SUBDOMAIN"
SYMLINK_FILE="/etc/nginx/sites-enabled/$SUBDOMAIN"

# 0. Alte Config löschen, falls vorhanden
if [ -f "$CONFIG_FILE" ]; then
    echo "🗑 Alte Config-Datei für $FULL_DOMAIN gefunden. Lösche sie..."
    sudo rm "$CONFIG_FILE"
fi

if [ -L "$SYMLINK_FILE" ]; then
    echo "🗑 Alter Symlink für $FULL_DOMAIN gefunden. Lösche ihn..."
    sudo rm "$SYMLINK_FILE"
fi

# 1. Neue NGINX Config erstellen
echo "🛠 Erstelle neue NGINX-Config für $FULL_DOMAIN auf Port $PORT..."

sudo tee "$CONFIG_FILE" > /dev/null <<EOF
server {
    listen 80;
    server_name $FULL_DOMAIN;

    # Weiterleitung auf HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $FULL_DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$FULL_DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$FULL_DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_http_version 1.1;

        # Websocket-Support
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # CORS-Header für alle Anfragen
        add_header Access-Control-Allow-Origin \$http_origin always;
        add_header Access-Control-Allow-Credentials true always;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS, PUT, DELETE" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Requested-With" always;

        # Spezielle Behandlung für Preflight (OPTIONS)
        if (\$request_method = OPTIONS) {
            add_header Access-Control-Allow-Origin \$http_origin;
            add_header Access-Control-Allow-Methods "GET, POST, OPTIONS, PUT, DELETE";
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Requested-With";
            add_header Content-Length 0;
            add_header Content-Type text/plain;
            return 204;
        }
    }
}
EOF

# 2. Neuen Symlink setzen
sudo ln -s "$CONFIG_FILE" "$SYMLINK_FILE"
echo "✅ Neuer Symlink für $FULL_DOMAIN erstellt."

# 3. NGINX Config testen und reloaden
echo "🔍 Teste NGINX Config..."
if sudo nginx -t; then
    echo "🔄 Reload NGINX..."
    sudo systemctl reload nginx
else
    echo "❌ Fehler in NGINX-Config. Abbruch."
    exit 1
fi

# 4. SSL-Zertifikat prüfen oder erstellen
if sudo certbot certificates | grep -q "$FULL_DOMAIN"; then
    echo "🔒 Zertifikat für $FULL_DOMAIN existiert bereits. Erneuere falls nötig..."
    sudo certbot renew --cert-name "$FULL_DOMAIN"
else
    echo "🆕 Fordere neues SSL-Zertifikat für $FULL_DOMAIN an..."
    sudo certbot --nginx -d "$FULL_DOMAIN"
fi

echo "🎉 Setup für $FULL_DOMAIN abgeschlossen!"