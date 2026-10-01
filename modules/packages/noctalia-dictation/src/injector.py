import logging
import shutil
import subprocess
import time

logger = logging.getLogger("noctalia-dictation")

def inject_text(text: str) -> None:
    """Inject text into active Wayland window via atomic clipboard paste (Shift+Insert)."""
    if not text:
        return

    # 1. Copy text to Wayland clipboard
    if shutil.which("wl-copy"):
        try:
            subprocess.run(["wl-copy", text], check=True)
        except Exception as e:
            logger.error("Failed to copy text to clipboard via wl-copy: %s", e)
    else:
        logger.warning("wl-copy not found in PATH")
    # 2. Give Wayland compositor a brief moment to update clipboard
    time.sleep(0.05)

    # 3. Simulate Shift+Insert to paste atomically without typing individual chars/newlines
    if shutil.which("wtype"):
        try:
            subprocess.run(["wtype", "-M", "shift", "-k", "Insert", "-m", "shift"], check=True)
        except Exception as e:
            logger.error("Failed to simulate Shift+Insert via wtype: %s", e)
    else:
        logger.warning("wtype not found in PATH")
