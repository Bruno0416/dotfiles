import json
from pathlib import Path

def hex_to_rgb(h):
    h = h.lstrip("#")
    return [int(h[i:i+2], 16) for i in (0, 2, 4)]

def get_pywal_colors():
    wal_file = Path.home() / ".cache/wal/colors.json"
    with open(wal_file) as f:
        wal = json.load(f)

    # Usamos colores que se ven bien para UI
    return {
        "primary": hex_to_rgb(wal["colors"]["color4"]),     # azul
        "accent": hex_to_rgb(wal["colors"]["color5"]),      # magenta
        "background": hex_to_rgb(wal["special"]["background"]),
        "foreground": hex_to_rgb(wal["special"]["foreground"]),
    }
