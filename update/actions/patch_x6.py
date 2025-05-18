import logging
import subprocess
import shutil
from pathlib import Path

from config import STRATEGIES_DIR
import re

logger = logging.getLogger(__name__)

def run():
    fname = "NostalgiaForInfinityX6.py"
    file = STRATEGIES_DIR / fname
    # Patch grind multiplier in X6 strategy
    content = file.read_text()
    patched = re.sub(
        r'(grind_mode_stake_multiplier_spot\s*=\s*)\[[^\]]*\]',
        r"\1[1.0, 0.30, 0.40, 0.50, 0.60, 0.70]",
        content
    )
    # Update grinding_v1_max_stake to 1.0
    patched = re.sub(
        r'^(grinding_v1_max_stake\s*=\s*)\d+(\.\d+)?',
        r'\g<1>1.0',
        patched,
        flags=re.MULTILINE
    )
    file.write_text(patched)