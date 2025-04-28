#!/bin/bash

# Script zum Anlegen einer neuen Subdomain-Weiterleitung mit SSL und CORS für Freqtrade-Bots

# -----------------------------------
# 1. Eingabe prüfen
# -----------------------------------
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <subdomain> <port>"
    exit 1
fi

SUBDOMAIN=$1
PORT=$2
DOMAIN="florianlenz.com"
FULL_DOMAIN="$SUBDOMAIN.$DOMAIN"

CONFIG_FILE="/etc/nginx/sites-available/$SUBDOMAIN"
SYMLINK_FILE="/etc/nginx/sites-enabled/$SUBDOMAIN"

# -----------------------------------
# 2. Alte Configs aufräumen
# -----------------------------------
if [ -f "$CONFIG_FILE" ]; then
    echo "🗑 Entferne alte NGINX-Config für $FULL_DOMAIN..."
    sudo rm "$CONFIG_FILE"
fi

if [ -L "$SYMLINK_FILE" ]; then
    echo "🗑 Entferne alten Symlink für $FULL_DOMAIN..."
    sudo rm "$SYMLINK_FILE"
fi

# -----------------------------------
# 3. Neue NGINX-Config erstellen
# -----------------------------------
echo "🛠 Erstelle neue NGINX-Config für $FULL_DOMAIN auf Port $PORT..."

sudo tee "$CONFIG_FILE" > /dev/null <<EOF
server {
    listen 80;
    server_name $FULL_DOMAIN;

    # Weiterleitung auf HTTPS
    return 301 https://$host$request_uri;
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
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # CORS-Header für alle Anfragen
        add_header Access-Control-Allow-Origin * always;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS, PUT, DELETE" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Requested-With" always;

        # Spezielle Behandlung für Preflight (OPTIONS)
        if ($request_method = OPTIONS) {
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods "GET, POST, OPTIONS, PUT, DELETE";
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Requested-With";
            add_header Content-Length 0;
            add_header Content-Type text/plain;
            return 204;
        }
    }
}
EOF

# -----------------------------------
# 4. Symlink setzen
# -----------------------------------
echo "🔗 Setze Symlink..."
sudo ln -s "$CONFIG_FILE" "$SYMLINK_FILE"

# -----------------------------------
# 5. NGINX testen und neu laden
# -----------------------------------
echo "🔍 Teste neue NGINX-Config..."
if sudo nginx -t; then
    echo "🔄 Lade NGINX neu..."
    sudo systemctl reload nginx
else
    echo "❌ Fehler in NGINX-Config. Abbruch."
    exit 1
fi

# -----------------------------------
# 6. SSL-Zertifikat prüfen/erstellen
# -----------------------------------
if sudo certbot certificates | grep -q "$FULL_DOMAIN"; then
    echo "🔒 Zertifikat für $FULL_DOMAIN existiert bereits. Versuche Erneuerung..."
    sudo certbot renew --cert-name "$FULL_DOMAIN"
else
    echo "🆕 Fordere neues SSL-Zertifikat an für $FULL_DOMAIN..."
    sudo certbot --nginx -d "$FULL_DOMAIN"
fi

echo "🎉 Setup für $FULL_DOMAIN abgeschlossen!"
