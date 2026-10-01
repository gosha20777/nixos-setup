import logging
import shutil
import subprocess

logger = logging.getLogger("noctalia-dictation")


def inject_text(text: str) -> None:
    """Type text into the active Wayland window via the virtual keyboard protocol.

    Typing (rather than clipboard paste) keeps the user's clipboard untouched
    and works regardless of whether the target app would paste from CLIPBOARD
    or PRIMARY (the old Shift+Insert paste read PRIMARY in some apps, inserting
    stale mouse selections). Newlines become spaces so Enter never sends a
    chat message or breaks a line mid-text — the refine prompt already demands
    a single paragraph, this is the safety net.
    """
    if not text:
        return

    if not shutil.which("wtype"):
        logger.error("wtype not found in PATH, cannot type text")
        return

    typing_text = " ".join(text.splitlines()).strip()
    if not typing_text:
        return

    try:
        subprocess.run(["wtype", typing_text], check=True)
    except Exception as e:
        logger.error("Failed to type text via wtype: %s", e)
