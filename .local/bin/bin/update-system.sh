#!/bin/bash

# --- CONFIGURACIÓN DE DEBUG ---
LOG="/tmp/waypaper_debug.log"

# Escribimos la hora de inicio para separar ejecuciones
echo "------------------------------------------------" >>"$LOG"
echo "Iniciando script a las: $(date)" >>"$LOG"
echo "Usuario actual: $(whoami)" >>"$LOG"
echo "Wallpaper recibido: $1" >>"$LOG"

# --- 1. Definir Variables ---
wallpaper="$1"
WAL_PATH="wal"

# --- 2. PRIORIDAD ALTA: Actualizar fondo de SDDM ---
echo "[SDDM] Intentando ejecutar update-sddm-bg.sh..." >>"$LOG"

# EJECUCIÓN CON DEBUG:
# 1. Usamos ruta absoluta (/home/bruno...)
# 2. '>> "$LOG" 2>&1' significa: guarda el éxito Y los errores en el archivo log
sudo /home/bruno/.local/bin/update-sddm-bg.sh "$wallpaper" >>"$LOG" 2>&1

# Chequeamos si el comando anterior funcionó (exit code 0 = éxito)
if [ $? -eq 0 ]; then
  echo "[SDDM] ÉXITO: El script de SDDM terminó bien." >>"$LOG"
else
  echo "[SDDM] ERROR: El script de SDDM falló. Mira las líneas de arriba." >>"$LOG"
fi

# --- 3. Generar Colores y Cache (Pywal) ---
echo "[Pywal] Generando colores..." >>"$LOG"
$WAL_PATH -i "$wallpaper" -n >>"$LOG" 2>&1

# --- 3.5. Matugen + Inyección Directa (Anti-Cache) ---
echo "[Matugen] Aplicando colores..." >>"$LOG"

if command -v matugen &>/dev/null; then
  # 1. Generamos el CSS en un archivo temporal
  matugen image "$wallpaper" >>"$LOG" 2>&1

  # 2. Definimos rutas
  GTK_FILE="$HOME/.config/gtk-4.0/gtk.css"
  MATUGEN_FILE="$HOME/.config/gtk-4.0/matugen.css"

  # 3. INYECCIÓN DIRECTA:
  # Borramos el gtk.css y lo creamos de nuevo con el contenido pegado.
  # Esto elimina la caché del @import.

  # Escribimos las cabeceras estándar
  echo "@import url('libadwaita.css');" >"$GTK_FILE"
  echo "@import url('libadwaita-tweaks.css');" >>"$GTK_FILE"
  echo "" >>"$GTK_FILE"
  echo "/* --- COLORES INYECTADOS POR MATUGEN --- */" >>"$GTK_FILE"

  # Pegamos el contenido RAW del archivo de matugen aquí mismo
  if [ -f "$MATUGEN_FILE" ]; then
    cat "$MATUGEN_FILE" >>"$GTK_FILE"
  fi

  # 4. Forzamos la recarga visual (El Flash)
  # Usamos HighContrast porque es el que más "duele" a la vista del sistema y fuerza el repaint.

  CURRENT_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
  if [ -z "$CURRENT_THEME" ]; then CURRENT_THEME="Adwaita"; fi

  # Hacemos el switch
  gsettings set org.gnome.desktop.interface gtk-theme 'HighContrast'
  sleep 0.1
  gsettings set org.gnome.desktop.interface gtk-theme "$CURRENT_THEME"

  echo "[Matugen] CSS inyectado directamente y recargado." >>"$LOG"
else
  echo "[Matugen] ERROR: No instalado." >>"$LOG"
fi

# --- 4. Actualizar Enlace para HYPRLOCK ---
ln -sf "$wallpaper" /home/bruno/.cache/current_wallpaper

# --- 5. Recargar Componentes ---
echo "[Reload] Recargando componentes..." >>"$LOG"

# SwayNC
/home/bruno/.config/swaync/generate-colors.sh >>"$LOG" 2>&1
killall -SIGUSR1 swaync

# Rofi
/home/bruno/.config/rofi/generate-theme.sh >>"$LOG" 2>&1 &

# Waybar
killall -SIGUSR2 waybar

# Hyprland
hyprctl reload

# --- 6. Otros (VSCode) ---
VSCODE_THEME_DEST="/home/bruno/.vscode/extensions/dlasagno.wal-theme-1.2.0/themes/wal.json"
WAL_THEME_SOURCE="/home/bruno/.cache/wal/vstheme.json"

if [ -f "$WAL_THEME_SOURCE" ]; then
  cp "$WAL_THEME_SOURCE" "$VSCODE_THEME_DEST"
  echo "[VSCode] Tema actualizado." >>"$LOG"
fi

# --- 7. Cargar colores a chromium
~/.local/bin/apply-pywal-chromium.sh

echo "Script finalizado." >>"$LOG"
notify-send -a "Hyprland" "Wallpaper Changed" "Check /tmp/waypaper_debug.log for details" -i "$wallpaper"
