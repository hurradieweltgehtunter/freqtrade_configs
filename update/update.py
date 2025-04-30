#!/usr/bin/env python3

import logging
import os
import sys
import importlib
from pathlib import Path
from config import LOGFILE, LOG_DIR, BASE_DIR, ACTIONS_DIR

# === Setup Logging ===
LOG_DIR.mkdir(parents=True, exist_ok=True)

# Logging konfigurieren mit TimedRotatingFileHandler
from logging.handlers import TimedRotatingFileHandler

logger = logging.getLogger()
logger.setLevel(logging.INFO)
logger.handlers.clear()

formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')

# Log-Datei wird täglich rotiert, 7 Backups werden behalten
file_handler = TimedRotatingFileHandler(LOGFILE, when="midnight", backupCount=7, encoding="utf-8")
file_handler.setFormatter(formatter)

console_handler = logging.StreamHandler()
console_handler.setFormatter(formatter)

logger.addHandler(file_handler)
logger.addHandler(console_handler)

# === Load .env ===
from dotenv import load_dotenv
dotenv_path = BASE_DIR / ".env"
if dotenv_path.exists():
    load_dotenv(dotenv_path)
    logger.info("✅ .env geladen")
else:
    logger.warning(f"⚠️  .env Datei nicht gefunden! {dotenv_path}")
    exit()

# === Execute update actions ===
sys.path.insert(0, str(ACTIONS_DIR))

def run_actions():
    logger.info("")
    logger.info("===== Update gestartet =====")
    # Manuell festgelegte Reihenfolge der Actions
    actions_order = [
        "update_config_repo",
        "update_nfi_repo",
        "reload_botconfigs"
    ]

    for module_name in actions_order:
        try:
            logger.info(f"➡️  Starte Aktion: {module_name}")
            module = importlib.import_module(module_name)
            module.run()
            logger.info(f"✅ Aktion abgeschlossen: {module_name}")
        except Exception as e:
            logger.error(f"❌ Fehler bei Aktion {module_name}: {e}")

    logger.info("===== Update abgeschlossen =====")

if __name__ == "__main__":
    run_actions()