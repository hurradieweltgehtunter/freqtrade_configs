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

    logger.info("Patching X6, set grind_mode_stake_multiplier_spot to [1.0, 0.30, 0.40, 0.50, 0.60, 0.70] and grinding_v1_max_stake to 1.0")

    # Patch grind multiplier in X6 strategy
    content = file.read_text()
    patched, count = re.subn(
        r'(grind_mode_stake_multiplier_spot\s*=\s*)\[[^\]]*\]',
        r"\1[1.0, 0.30, 0.40, 0.50, 0.60, 0.70]",
        content
    )
    if count > 0:
        logger.info(f"Patched grind_mode_stake_multiplier_spot: {count} replacement(s)")

    # Update grinding_v1_max_stake to 1.0
    patched, count = re.subn(
        r'^(grinding_v1_max_stake\s*=\s*)\d+(\.\d+)?',
        r'\g<1>1.0',
        patched,
        flags=re.MULTILINE
    )
    if count > 0:
        logger.info(f"Patched grinding_v1_max_stake: {count} replacement(s)")

    # Update grinding_v2_grind_1_stakes_spot to [1, 0.30, 0.35, 0.40]
    patched, count = re.subn(
        r'^(\s*grinding_v2_grind_1_stakes_spot\s*=\s*)\[[^\]]*\]',
        r'\1[1, 0.30, 0.35, 0.40]',
        patched,
        flags=re.MULTILINE
    )
    if count > 0:
        logger.info(f"Patched grinding_v2_grind_1_stakes_spot: {count} replacement(s)")

    # Patch Grinding entry notifications to include multiplier
    patched, count = re.subn(
        r'(self\.dp\.send_msg\(\s*f"Grinding entry \(grind_1_entry\))([^"]*)"\)',
        r'\1, mult: {grind_1_stakes[grind_1_sub_grind_count]}\2")',
        patched
    )
    if count > 0:
        logger.info(f"Patched dp.send_msg grind_1_entry: {count} replacement(s)")
    patched, count = re.subn(
        r'(log\.info\(\s*f"Grinding entry \(grind_1_entry\))([^"]*)"\)',
        r'\1, mult: {grind_1_stakes[grind_1_sub_grind_count]}\2")',
        patched
    )
    if count > 0:
        logger.info(f"Patched log.info grind_1_entry: {count} replacement(s)")

    file.write_text(patched)
