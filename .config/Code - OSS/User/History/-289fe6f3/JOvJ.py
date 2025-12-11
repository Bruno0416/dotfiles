import time
import os
from pathlib import Path
from apply import apply_theme

WAL_COLORS = Path.home() / ".cache/wal/colors.json"

def watch():
    print("Esperando cambios de pywal...")
    last_mtime = WAL_COLORS.stat().st_mtime

    while True:
        time.sleep(1)
        new_mtime = WAL_COLORS.stat().st_mtime

        if new_mtime != last_mtime:
            last_mtime = new_mtime
            print("Pywal cambió → Aplicando Chromium Wal Theme…")
            apply_theme()
