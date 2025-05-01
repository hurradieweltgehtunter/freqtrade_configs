import logging
import shutil
import subprocess
import os
from config import BASE_DIR, USER_DATA, NFI_DIR, STRATEGIES_DIR

logger = logging.getLogger(__name__)

def run() -> bool:
    logger.info("🔍 Prüfe NostalgiaForInfinity Repo...")

    if not NFI_DIR.exists():
        logger.error(f"❌ NFI Repo nicht gefunden unter {NFI_DIR}")
        return False

    try:
        os.chdir(NFI_DIR)
        local_commit_before = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip()
        subprocess.run(["git", "pull"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        local_commit_after = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip()
    except subprocess.CalledProcessError as e:
        logger.error(f"❌ Fehler beim Pull des NFI Repos: {e}")
        return False

    if local_commit_before == local_commit_after:
        logger.info("ℹ️  Keine Änderungen im NFI Repo. Überspringe Strategie-Update.")
        return False

    logger.info("🔁 Änderungen erkannt. Aktualisiere Strategien...")

    for fname in ["NostalgiaForInfinityX5.py", "NostalgiaForInfinityX6.py"]:
        src = NFI_DIR / fname
        dst = STRATEGIES_DIR / fname
        if src.exists():
            shutil.copy2(src, dst)
            logger.info(f"✅ {fname} erfolgreich kopiert.")
        else:
            logger.warning(f"⚠️  {fname} nicht gefunden.")

    return True