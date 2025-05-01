import logging
import subprocess
import shutil
from pathlib import Path

from config import CONFIG_REPO, USER_DATA, BASE_DIR

logger = logging.getLogger(__name__)

def run():
    if not CONFIG_REPO.exists():
        logger.error(f"❌ Freqtrade Config Repo nicht gefunden: {CONFIG_REPO}")
        return False

    # Pull latest changes
    logger.info("📥 Aktualisiere freqtrade_configs Repo...")
    local_commit_before = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=CONFIG_REPO).decode().strip()
    subprocess.run(["git", "fetch", "--all"], cwd=CONFIG_REPO, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    subprocess.run(["git", "reset", "--hard", "origin/main"], cwd=CONFIG_REPO, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    local_commit_after = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=CONFIG_REPO).decode().strip()

    if local_commit_before == local_commit_after:
        logger.info("🔁 Keine Änderungen im Config-Repo gefunden.")
        return False

    commit_message = subprocess.check_output(["git", "log", "-1", "--pretty=%B"], cwd=CONFIG_REPO).decode().strip()

    logger.info(f"📂 Änderungen erkannt – neuester commit: {commit_message}")
    logger.info("Starte Kopiervorgänge…")

    deploy_configs = USER_DATA / "configs"
    if deploy_configs.exists():
        logger.info("🧹 Leere Config-Zielverzeichnis...")
        shutil.rmtree(deploy_configs)
    deploy_configs.mkdir(parents=True, exist_ok=True)

    config_source = CONFIG_REPO / "configs"
    if config_source.exists():
        for item in config_source.iterdir():
            shutil.copy(item, deploy_configs)
        logger.info("📁 Config-Dateien kopiert.")
    else:
        logger.warning("⚠️ Kein 'configs' Verzeichnis im Config-Repo gefunden.")

    for file_name in ["docker-compose.yml", "Dockerfile.custom", "Dockerfile.watchdog"]:
        src = CONFIG_REPO / file_name
        if src.exists():
            shutil.copy(src, BASE_DIR / file_name)
            logger.info(f"📄 {file_name} kopiert.")
        else:
            logger.warning(f"⚠️ {file_name} nicht gefunden im Repo.")

    scripts_dir = CONFIG_REPO / "scripts"
    if scripts_dir.exists():
        for script in scripts_dir.glob("*"):
            script.chmod(script.stat().st_mode | 0o111)
        logger.info("🔧 Alle Skripte im 'scripts'-Ordner ausführbar gemacht.")
    else:
        logger.warning("⚠️ Kein 'scripts' Verzeichnis gefunden.")
    
    return True