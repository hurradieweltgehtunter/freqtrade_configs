#!/bin/bash

# Automatisch ermittelter Projektpfad (zwei Ebenen über diesem Skript)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Virtuelle Umgebung aktivieren
source "$PROJECT_DIR/.venv/bin/activate"

# Abhängigkeiten installieren
pip install --quiet --disable-pip-version-check -r "$PROJECT_DIR/requirements.txt"

# Hauptskript ausführen
python3 "$PROJECT_DIR/update.py"