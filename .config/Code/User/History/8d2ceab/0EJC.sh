#!/bin/bash

# --- 1. Definir Variables ---
# Capturamos la imagen que envía Waypaper en una variable para usarla fácil
wallpaper="$1"
WAL_PATH="/home/bruno/.local/bin/wal"

# --- 2. Generar Colores y Cache (Pywal) ---
# -n evita cambiar el fondo de terminales abiertas (opcional)
$WAL_PATH -i "$wallpaper" -n

# --- 3. Actualizar Enlace para HYPRLOCK (CRUCIAL) ---
# Aquí estaba el error: antes usabas una variable no definida.
# Ahora apuntamos el enlace 'current_wallpaper' a la nueva imagen.
ln -sf "$wallpaper" ~/.cache/current_wallpaper

# --- 4. Recargar Componentes ---

# SwayNC
~/.config/swaync/generate-colors.sh
killall -SIGUSR1 swaync

# Rofi
~/.config/rofi/generate-theme.sh &

# Waybar (Recarga suave)
killall -SIGUSR2 waybar

# Hyprland (Para que tome los bordes de ventana nuevos)
hyprctl reload

# --- 5. Otros (VSCode, etc) ---
# (Dejé tus rutas tal cual, si tienes un comando 'cp' para el tema de vscode, iría aquí)
VSCODE_THEME_DEST="/home/bruno/.vscode/extensions/dlasagno.wal-theme-1.2.0/themes/wal.json" 
WAL_THEME_SOURCE="/home/bruno/.cache/wal/vstheme.json"
