import logging
import subprocess
import shutil
from pathlib import Path

from config import CONFIG_REPO, USER_DATA, BASE_DIR

def run():
    log = logging.getLogger()

    if not CONFIG_REPO.exists():
        log.error(f"❌ Freqtrade Config Repo nicht gefunden: {CONFIG_REPO}")
        return

    # Pull latest changes
    log.info("📥 Aktualisiere freqtrade_configs Repo...")
    local_commit_before = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=CONFIG_REPO).decode().strip()
    subprocess.run(["git", "fetch", "--all"], cwd=CONFIG_REPO, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    subprocess.run(["git", "reset", "--hard", "origin/main"], cwd=CONFIG_REPO, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    local_commit_after = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=CONFIG_REPO).decode().strip()

    if local_commit_before == local_commit_after:
        log.info("🔁 Keine Änderungen im Config-Repo gefunden.")
        return

    log.info("📂 Änderungen erkannt – starte Kopiervorgänge...")

    deploy_configs = USER_DATA / "configs"
    if deploy_configs.exists():
        log.info("🧹 Leere Config-Zielverzeichnis...")
        shutil.rmtree(deploy_configs)
    deploy_configs.mkdir(parents=True, exist_ok=True)

    config_source = CONFIG_REPO / "configs"
    if config_source.exists():
        for item in config_source.iterdir():
            shutil.copy(item, deploy_configs)
        log.info("📁 Config-Dateien kopiert.")
    else:
        log.warning("⚠️ Kein 'configs' Verzeichnis im Config-Repo gefunden.")

    for file_name in ["docker-compose.yml", "Dockerfile.custom", "Dockerfile.watchdog"]:
        src = CONFIG_REPO / file_name
        if src.exists():
            shutil.copy(src, BASE_DIR / file_name)
            log.info(f"📄 {file_name} kopiert.")
        else:
            log.warning(f"⚠️ {file_name} nicht gefunden im Repo.")

    scripts_dir = CONFIG_REPO / "scripts"
    if scripts_dir.exists():
        for script in scripts_dir.glob("*"):
            script.chmod(script.stat().st_mode | 0o111)
        log.info("🔧 Alle Skripte im 'scripts'-Ordner ausführbar gemacht.")
    else:
        log.warning("⚠️ Kein 'scripts' Verzeichnis gefunden.")