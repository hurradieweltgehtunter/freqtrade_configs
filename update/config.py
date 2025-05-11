from pathlib import Path
import os

# Basisverzeichnis deines Projekts
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# Repos und wichtige Ordner
CONFIG_REPO = BASE_DIR / "freqtrade_configs"
USER_DATA = BASE_DIR / "user_data"
LOG_DIR = USER_DATA / "logs"
LOGFILE = LOG_DIR / "update.log"
SCRIPTS_DIR = CONFIG_REPO / "scripts"
ACTIONS_DIR = CONFIG_REPO / "update" / "actions"
CONFIGS_DIR = CONFIG_REPO / "configs"
STRATEGIES_DIR = USER_DATA / "strategies"
NFI_DIR = STRATEGIES_DIR / "NostalgiaForInfinity"

# Docker Container-Namen der Bots
# BOTS = [
#     "BinanceX5Spot",
#     "BitgetX5Spot",
#     "GateioX5Spot"
# ]

# Docker API Ports (Mapping: Containername → Port)
BOTS = {
    "BinanceX5Spot": 8081,
    "BitgetX5Spot": 8082,
    "GateioX5Spot": 8083,
    "BitgetX6Spot": 8084,
}

# .env Pfad
DOTENV_PATH = BASE_DIR / ".env"

# Update-Zielverzeichnis für Configs
DEPLOY_CONFIGS = USER_DATA / "configs"

# Einzelne Dateien
DOCKER_COMPOSE = CONFIG_REPO / "docker-compose.yml"
DOCKERFILE_CUSTOM = CONFIG_REPO / "Dockerfile.custom"
DOCKERFILE_WATCHDOG = CONFIG_REPO / "Dockerfile.watchdog"