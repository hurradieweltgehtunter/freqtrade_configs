import logging
import shutil
import subprocess
import os
from update.config import BASE_DIR, USER_DATA, NFI_DIR

def run():
    logging.info("🔍 Prüfe NostalgiaForInfinity Repo...")

    if not NFI_DIR.exists():
        logging.error(f"❌ NFI Repo nicht gefunden unter {NFI_DIR}")
        return

    try:
        os.chdir(NFI_DIR)
        local_commit_before = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip()
        subprocess.run(["git", "pull"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        local_commit_after = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip()
    except subprocess.CalledProcessError as e:
        logging.error(f"❌ Fehler beim Pull des NFI Repos: {e}")
        return

    if local_commit_before == local_commit_after:
        logging.info("ℹ️  Keine Änderungen im NFI Repo. Überspringe Strategie-Update.")
        return

    logging.info("🔁 Änderungen erkannt. Aktualisiere Strategien...")

    dest_dir = USER_DATA / "strategies"
    for fname in ["NostalgiaForInfinityX5.py", "NostalgiaForInfinityX6.py"]:
        src = NFI_DIR / fname
        dst = dest_dir / fname
        if src.exists():
            shutil.copy2(src, dst)
            logging.info(f"✅ {fname} erfolgreich kopiert.")
        else:
            logging.warning(f"⚠️  {fname} nicht gefunden.")