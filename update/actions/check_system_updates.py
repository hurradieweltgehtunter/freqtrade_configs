import logging
import os

from ..utils.telegram import send_telegram_message

logger = logging.getLogger(__name__)

def run():
    """
    Action: Prüft, ob echte Updates verfügbar sind.
    Sendet Telegram Nachricht nur bei regulären Updates.
    """
    updates_file = "/var/lib/update-notifier/updates-available"

    telegram_token = os.environ.get("BINANCEX5SPOT_TELEGRAM__TOKEN")
    telegram_chat_id = os.environ.get("BINANCEX5SPOT_TELEGRAM__CHAT_ID")

    try:
        logger.info("➡️ Starte Aktion: check_server_updates")
        if os.path.exists(updates_file):
            with open(updates_file, 'r') as f:
                updates_info = f.read().strip()

            # Prüfen ob KEINE Updates anstehen
            if "10 updates can be applied immediately." in updates_info:
                logger.info("✅ Keine regulären Updates verfügbar.")
                return False

            # Wenn Updates anstehen → Nachricht
            message = (
                f"⚠️ Dein Server hat verfügbare Updates!\n\n"
                f"{updates_info}\n\n"
                f"👉 Bitte führe 'sudo apt update && sudo apt upgrade' aus."
            )

            logger.warning(message)
            send_telegram_message(message, telegram_token, telegram_chat_id)
            logger.info("✅ System Updates Hinweis erfolgreich gesendet.")
            return True
        else:
            logger.info("✅ Datei update-notifier nicht vorhanden.")
            return False

    except Exception as e:
        logger.error(f"❌ Fehler bei check_server_updates: {e}")
        return False