import json
import os
from pathlib import Path
from colors import get_pywal_colors

PREFS_PATH = Path.home() / ".config/chromium/Default/Preferences"

def apply_theme():
    colors = get_pywal_colors()

    with open(PREFS_PATH) as f:
        prefs = json.load(f)

    prefs["browser"]["theme_mode"] = "CUSTOM"
    prefs["browser"]["color_scheme"] = 2
    prefs["browser"]["color_scheme_seed"] = colors["primary"]

    prefs["browser"]["custom_colors"] = {
        "frame": colors["background"],
        "toolbar": colors["background"],
        "ntp_background": colors["background"],
        "ntp_text": colors["foreground"],
        "tab_background": colors["background"],
        "tab_foreground": colors["foreground"],
        "button_background": colors["primary"],
        "button_foreground": colors["foreground"],
        "accent": colors["accent"],
    }

    prefs["extensions"]["theme"]["id"] = ""

    with open(PREFS_PATH, "w") as f:
        json.dump(prefs, f, indent=2)

    # 🔥 Método estable en Arch + Wayland: reiniciar GPU process
    os.system('pkill -SIGTERM -f "chromium.*--type=gpu-process"')

    print("✔ Tema aplicado (GPU process refrescado, sin crashear)")
