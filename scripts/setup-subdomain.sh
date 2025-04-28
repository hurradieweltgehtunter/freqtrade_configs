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

# 1. NGINX Config erstellen
echo "🛠 Erstelle NGINX-Config für $FULL_DOMAIN auf Port $PORT..."

sudo tee "$CONFIG_FILE" > /dev/null <<EOF
server {
    listen 80;
    server_name $FULL_DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# 2. Symlink setzen (nur wenn noch nicht vorhanden)
if [ ! -e "/etc/nginx/sites-enabled/$SUBDOMAIN" ]; then
    sudo ln -s "$CONFIG_FILE" "/etc/nginx/sites-enabled/$SUBDOMAIN"
    echo "✅ Symlink für $SUBDOMAIN gesetzt."
else
    echo "ℹ️  Symlink für $SUBDOMAIN existiert bereits."
fi

# 3. NGINX Config testen und reloaden
echo "🔍 Teste NGINX Config..."
sudo nginx -t

echo "🔄 Reload NGINX..."
sudo systemctl reload nginx

# 4. Prüfen, ob bereits ein Zertifikat existiert
if sudo certbot certificates | grep -q "$FULL_DOMAIN"; then
    echo "🔒 Zertifikat für $FULL_DOMAIN existiert bereits. Erneuern falls nötig..."
    sudo certbot renew --cert-name "$FULL_DOMAIN"
else
    echo "🆕 Fordere neues SSL-Zertifikat für $FULL_DOMAIN an..."
    sudo certbot --nginx -d "$FULL_DOMAIN"
fi

echo "🎉 Setup für $FULL_DOMAIN abgeschlossen!"