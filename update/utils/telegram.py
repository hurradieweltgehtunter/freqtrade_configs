import requests
import logging
import os

logger = logging.getLogger(__name__)

def send_telegram_message(message: str, bot_token: str, chat_id: str) -> None:
    """
    Sendet eine Telegram Nachricht an das konfigurierte Chat.
    Holt die Daten aus Umgebungsvariablen, wenn keine Parameter übergeben wurden.

    :param message: Nachricht, die gesendet werden soll.
    :param bot_token: Telegram Bot Token aus env
    :param chat_id: Telegram Chat ID aus env
    """

    if not bot_token or not chat_id:
        logger.error("❌ Telegram Konfiguration fehlt. Nachricht wird nicht gesendet.")
        return

    url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": message,
        "parse_mode": "Markdown",
        "disable_web_page_preview": True
    }

    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()
        logger.info(f"✅ Telegram Nachricht erfolgreich gesendet. (Status: {response.status_code})")
    except requests.RequestException as e:
        logger.error(f"❌ Fehler beim Senden der Telegram Nachricht: {e}")