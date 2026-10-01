import shutil
import subprocess
import time


def inject_text(text: str) -> None:
    """Inject text into active Wayland window via atomic clipboard paste (Shift+Insert)."""
    if not text:
        return

    # 1. Copy text to Wayland clipboard
    if shutil.which("wl-copy"):
        try:
            subprocess.run(["wl-copy", text], check=False)
        except Exception:
            pass

    # 2. Give Wayland compositor a brief moment to update clipboard
    time.sleep(0.05)

    # 3. Simulate Shift+Insert to paste atomically without typing individual chars/newlines
    if shutil.which("wtype"):
        try:
            subprocess.run(["wtype", "-M", "shift", "-k", "Insert", "-m", "shift"], check=False)
        except Exception:
            pass
