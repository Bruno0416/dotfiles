#!/bin/bash

# --- CONFIGURACIÓN DE DEBUG ---
LOG="/tmp/waypaper_debug.log"

# Escribimos la hora de inicio para separar ejecuciones
echo "------------------------------------------------" >> "$LOG"
echo "Iniciando script a las: $(date)" >> "$LOG"
echo "Usuario actual: $(whoami)" >> "$LOG"
echo "Wallpaper recibido: $1" >> "$LOG"

# --- 1. Definir Variables ---
wallpaper="$1"
WAL_PATH="wal"

# --- 2. PRIORIDAD ALTA: Actualizar fondo de SDDM ---
echo "[SDDM] Intentando ejecutar update-sddm-bg.sh..." >> "$LOG"

# EJECUCIÓN CON DEBUG:
# 1. Usamos ruta absoluta (/home/bruno...)
# 2. '>> "$LOG" 2>&1' significa: guarda el éxito Y los errores en el archivo log
sudo /home/bruno/.local/bin/update-sddm-bg.sh "$wallpaper" >> "$LOG" 2>&1

# Chequeamos si el comando anterior funcionó (exit code 0 = éxito)
if [ $? -eq 0 ]; then
    echo "[SDDM] ÉXITO: El script de SDDM terminó bien." >> "$LOG"
else
    echo "[SDDM] ERROR: El script de SDDM falló. Mira las líneas de arriba." >> "$LOG"
fi

# --- 3. Generar Colores y Cache (Pywal) ---
echo "[Pywal] Generando colores..." >> "$LOG"
$WAL_PATH -i "$wallpaper" -n >> "$LOG" 2>&1

# --- 4. Actualizar Enlace para HYPRLOCK ---
ln -sf "$wallpaper" /home/bruno/.cache/current_wallpaper

# --- 5. Recargar Componentes ---
echo "[Reload] Recargando componentes..." >> "$LOG"

# SwayNC
/home/bruno/.config/swaync/generate-colors.sh >> "$LOG" 2>&1
killall -SIGUSR1 swaync

# Rofi
/home/bruno/.config/rofi/generate-theme.sh >> "$LOG" 2>&1 &

# Waybar
killall -SIGUSR2 waybar

# Hyprland
hyprctl reload

# --- 6. Otros (VSCode) ---
VSCODE_THEME_DEST="/home/bruno/.vscode/extensions/dlasagno.wal-theme-1.2.0/themes/wal.json" 
WAL_THEME_SOURCE="/home/bruno/.cache/wal/vstheme.json"

if [ -f "$WAL_THEME_SOURCE" ]; then
    cp "$WAL_THEME_SOURCE" "$VSCODE_THEME_DEST"
    echo "[VSCode] Tema actualizado." >> "$LOG"
fi

# --- 7. Cargar colores a chromium
~/.local/bin/apply-pywal-chromium.sh

echo "Script finalizado." >> "$LOG"
notify-send -a "Hyprland" "Wallpaper Changed" "Check /tmp/waypaper_debug.log for details" -i "$wallpaper"
