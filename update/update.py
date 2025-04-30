#!/usr/bin/env python3

import logging
import os
import sys
import importlib
from pathlib import Path

# === Setup Logging ===
LOG_DIR = Path(__file__).resolve().parent.parent / "user_data" / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)
LOGFILE = LOG_DIR / "update.log"

logging.basicConfig(
    filename=LOGFILE,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
console = logging.StreamHandler(sys.stdout)
console.setLevel(logging.INFO)
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
console.setFormatter(formatter)
logging.getLogger().addHandler(console)

# === Load .env ===
from dotenv import load_dotenv
dotenv_path = Path(__file__).resolve().parent / ".env"
if dotenv_path.exists():
    load_dotenv(dotenv_path)
    logging.info("✅ .env geladen")
else:
    logging.warning("⚠️  .env Datei nicht gefunden!")
    exit()

# === Execute update actions ===
ACTIONS_DIR = Path(__file__).resolve().parent / "actions"
sys.path.insert(0, str(ACTIONS_DIR))

def run_actions():
    logging.info("===== Update gestartet =====")
    # Manuell festgelegte Reihenfolge der Actions
    actions_order = [
        "update_config_repo",
        "update_nfi_repo",
        "reload_botconfigs"
    ]

    for module_name in actions_order:
        try:
            logging.info(f"➡️  Starte Aktion: {module_name}")
            module = importlib.import_module(module_name)
            module.run()
            logging.info(f"✅ Aktion abgeschlossen: {module_name}")
        except Exception as e:
            logging.error(f"❌ Fehler bei Aktion {module_name}: {e}")

    logging.info("===== Update abgeschlossen =====")

if __name__ == "__main__":
    run_actions()