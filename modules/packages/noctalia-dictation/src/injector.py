import shutil
import subprocess


def inject_text(text: str) -> None:
    """Inject text into active Wayland window via wtype and copy to clipboard."""
    if not text:
        return

    # Always copy to clipboard
    if shutil.which("wl-copy"):
        try:
            subprocess.run(["wl-copy", text], check=False)
        except Exception:
            pass

    # Type into active window via Wayland virtual keyboard
    if shutil.which("wtype"):
        try:
            subprocess.run(["wtype", "--", text], check=False)
        except Exception:
            pass
