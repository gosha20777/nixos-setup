"""Everforest Warm visual theme for Rich TUI."""

from rich.console import Console
from rich.theme import Theme

# Everforest Warm Palette
PALETTE = {
    "bg_dim": "#232a2e",
    "bg0": "#2d353b",
    "bg1": "#343f44",
    "fg": "#d3c6aa",
    "red": "#e67e80",
    "orange": "#e69875",
    "yellow": "#dbbc7f",
    "green": "#a7c080",
    "aqua": "#83c092",
    "blue": "#7fbbb3",
    "purple": "#d699b6",
    "muted": "#859289",
}

installer_theme = Theme({
    "info": f"bold {PALETTE['blue']}",
    "warning": f"bold {PALETTE['orange']}",
    "error": f"bold {PALETTE['red']}",
    "success": f"bold {PALETTE['green']}",
    "accent": f"bold {PALETTE['aqua']}",
    "muted": PALETTE["muted"],
    "title": f"bold {PALETTE['green']}",
    "prompt": f"bold {PALETTE['yellow']}",
    "header": f"bold {PALETTE['fg']} on {PALETTE['bg1']}",
    "fg": PALETTE["fg"],
    "green": PALETTE["green"],
    "red": PALETTE["red"],
    "yellow": PALETTE["yellow"],
    "orange": PALETTE["orange"],
    "blue": PALETTE["blue"],
    "aqua": PALETTE["aqua"],
    "bg0": PALETTE["bg0"],
    "bg1": PALETTE["bg1"],
})

console = Console(theme=installer_theme)
