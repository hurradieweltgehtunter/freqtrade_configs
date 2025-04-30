import os
import logging
import requests
from update.config import BOTS

logger = logging.getLogger(__name__)

def run():
    logger.info("🔁 Starte Reload der Freqtrade-Konfigurationen über API...")

    for bot_name, port in BOTS.items():
        username_env = f"{bot_name.upper()}_API_SERVER__USERNAME"
        password_env = f"{bot_name.upper()}_API_SERVER__PASSWORD"
        username = os.getenv(username_env)
        password = os.getenv(password_env)

        if not username or not password:
            logger.warning(f"⚠️  Keine Zugangsdaten für {bot_name} gefunden – überspringe...")
            continue

        url = f"http://localhost:{port}/api/v1/reload_config"
        try:
            response = requests.post(url, auth=(username, password))
            if response.status_code == 200:
                logger.info(f"✅ Reload erfolgreich für {bot_name}")
            else:
                logger.warning(f"❌ Fehler beim Reload von {bot_name}: {response.status_code} - {response.text}")
        except Exception as e:
            logger.error(f"❌ API-Aufruf fehlgeschlagen für {bot_name}: {e}")
