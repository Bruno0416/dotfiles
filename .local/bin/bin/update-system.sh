#!/bin/bash
# --- CONFIGURACIÓN ---
LOG="/tmp/waypaper_debug.log"
INPUT_WALLPAPER="$1" # Guardamos el input original
WAL_PATH="wal"

# --- FUNCIÓN DE LOGGING Y TIMER ---
START_TIME=$(date +%s.%N)
log_step() {
  local message="$1"
  local now=$(date +%s.%N)
  local elapsed=$(echo "$now - $START_TIME" | bc)
  echo "[T+${elapsed}s] $message" >>"$LOG"
}

# Reiniciar Log
echo "------------------------------------------------" >"$LOG"
echo "Iniciando script a las: $(date)" >>"$LOG"

# --- 0. SANITIZACIÓN / LIMPIEZA DE NOMBRE DE ARCHIVO ---
# Esto previene errores con ImageMagick/Walcord por espacios o caracteres raros (=, ?, etc)
log_step "Input recibido: $INPUT_WALLPAPER"

DIR=$(dirname "$INPUT_WALLPAPER")
FILENAME=$(basename "$INPUT_WALLPAPER")
EXTENSION="${FILENAME##*.}"
NAME_ONLY="${FILENAME%.*}"

# Reemplazamos cualquier cosa que no sea letra, numero, punto o guion bajo con un guion bajo
CLEAN_NAME=$(echo "$NAME_ONLY" | sed -e 's/[^a-zA-Z0-9._-]//g')
NEW_FILENAME="${CLEAN_NAME}.${EXTENSION}"
CLEAN_PATH="$DIR/$NEW_FILENAME"

if [ "$INPUT_WALLPAPER" != "$CLEAN_PATH" ]; then
  mv "$INPUT_WALLPAPER" "$CLEAN_PATH"
  log_step "⚠ Archivo renombrado por seguridad: $FILENAME -> $NEW_FILENAME"
  wallpaper="$CLEAN_PATH"
else
  wallpaper="$INPUT_WALLPAPER"
fi

log_step "Wallpaper final a usar: $wallpaper"

# --- 1. GENERACIÓN DE COLORES (CRÍTICO - BLOQUEANTE) ---
# Pywal debe terminar antes de que otros plugins intenten leer los colores
log_step "[Pywal] Iniciando generación de colores..."
$WAL_PATH -i "$wallpaper" -n >>"$LOG" 2>&1
log_step "[Pywal] Colores generados."

# Matugen (Generador de temas GTK)
if command -v matugen &>/dev/null; then
  log_step "[Matugen] Iniciando generación..."
  matugen image "$wallpaper" >>"$LOG" 2>&1

  # Inyección CSS para Libadwaita
  GTK_FILE="$HOME/.config/gtk-4.0/gtk.css"
  MATUGEN_FILE="$HOME/.config/gtk-4.0/matugen.css"
  echo "@import url('libadwaita.css');" >"$GTK_FILE"
  echo "@import url('libadwaita-tweaks.css');" >>"$GTK_FILE"
  echo "" >>"$GTK_FILE"
  echo "/* --- COLORES INYECTADOS POR MATUGEN --- */" >>"$GTK_FILE"
  if [ -f "$MATUGEN_FILE" ]; then
    cat "$MATUGEN_FILE" >>"$GTK_FILE"
  fi
  log_step "[Matugen] CSS Inyectado."
else
  log_step "[Matugen] No instalado, saltando."
fi

# --- 2. CREAR COPIA WALLPAPER ---
# Aseguramos que el directorio destino exista
mkdir -p "$HOME/.cache"

# Convertimos la imagen de origen ($wallpaper) a formato PNG y la guardamos en el destino
magick "$wallpaper" "$HOME/.cache/current_wallpaper.png"

# --- 3. EJECUCIÓN PARALELA  ---
log_step "[Parallel] Lanzando tareas en segundo plano..."

# --- 4. SDDM ---
(
  if [ -f "$HOME/.local/bin/update-sddm-bg.sh" ]; then
    sudo -n $HOME/.local/bin/update-sddm-bg.sh "$wallpaper" >>"$LOG" 2>&1
  fi
) &

# --- 5. Rofi ---
(
  ROFI_SCRIPT="$HOME/.config/rofi/generate-theme.sh"
  if [ -x "$ROFI_SCRIPT" ] || [ -f "$ROFI_SCRIPT" ]; then
    log_step "[Rofi] Ejecutando generate-theme.sh..."
    # Intentamos ejecutarlo. Si no tiene permisos +x, usamos bash
    if [ -x "$ROFI_SCRIPT" ]; then
      "$ROFI_SCRIPT" >>"$LOG" 2>&1
    else
      bash "$ROFI_SCRIPT" >>"$LOG" 2>&1
    fi
    log_step "[Rofi] Actualizado."
  else
    log_step "[Rofi] ⚠ Script no encontrado en: $ROFI_SCRIPT"
  fi
) &

# --- 6. Recarga de GTK ---
(
  CURRENT_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
  [ -z "$CURRENT_THEME" ] && CURRENT_THEME="Adwaita"
  gsettings set org.gnome.desktop.interface gtk-theme 'HighContrast'
  sleep 0.1
  gsettings set org.gnome.desktop.interface gtk-theme "$CURRENT_THEME"
  log_step "[GTK-Reload] Tema refrescado."
) &

# --- 7. Componentes UI (SwayNC, Rofi, Waybar) ---
(
  if [ -f "/home/bruno/.config/swaync/generate-colors.sh" ]; then
    /home/bruno/.config/swaync/generate-colors.sh >>"$LOG" 2>&1
  fi
) &

# --- 8. Walcord - Discord ---
(
  log_step "[Walcord] Actualizando colores de Discord..."
  VENCORD_THEME_DIR="$HOME/.var/app/com.discordapp.Discord/config/Vencord/themes"
  VENCORD_THEME_VESKTOP="$HOME/.config/vesktop/themes"
  if command -v walcord &>/dev/null; then
    # Usamos la ruta limpia y apuntamos DIRECTAMENTE a la carpeta de Vencord
    walcord -i "$wallpaper" -o "$VENCORD_THEME_DIR/Walcord.theme.css" >>"$LOG" 2>&1
    walcord -i "$wallpaper" -o "$VENCORD_THEME_VESKTOP/Walcord.theme.css" >>"$LOG" 2>&1
    log_step "[Walcord] Tema regenerado en $VENCORD_THEME_DIR"
  else
    log_step "[Walcord] No instalado, saltando."
  fi
) &

# --- 9. Pywalfox ---
(
  log_step "[Pywalfox] Actualizando navegador..."
  if command -v pywalfox &>/dev/null; then
    pywalfox update >>"$LOG" 2>&1
    log_step "[Pywalfox] Firefox actualizado."
  else
    log_step "[Pywalfox] CLI no instalada (pip install pywalfox)."
  fi
) &

# --- 10. Actualizar Spotify ---
(
  # 1. Copiamos el archivo generado por Wal a la carpeta de Spicetify
  cp ~/.cache/wal/colors-spicetify.ini ~/.config/spicetify/Themes/Ziro/color.ini
  log_step "[Spotify] Archivo de tema actualizado (Watcher hará el resto)."
) &

# --- 11. Actualizar iconos Wlogout
(
  SRC_ICONS="$HOME/.config/wlogout/icons"
  CACHE_NORMAL="$HOME/.cache/wlogout/icons-normal"
  CACHE_ACTIVE="$HOME/.cache/wlogout/icons-active"
  WAL_COLOR_FILE="$HOME/.cache/wal/colors.sh"

  # 2. Verificar que existe la carpeta de origen
  if [ ! -d "$SRC_ICONS" ]; then
    echo "Error: No encuentro la carpeta de iconos en $SRC_ICONS"
    exit 1
  fi

  # 3. Importar colores de Pywal
  if [ -f "$WAL_COLOR_FILE" ]; then
    source "$WAL_COLOR_FILE"
  else
    echo "Error: No se han generado los colores de wal ($WAL_COLOR_FILE)"
    exit 1
  fi

  # 4. Crear carpetas si no existen
  mkdir -p "$CACHE_NORMAL" "$CACHE_ACTIVE"

  # 5. Copiar iconos originales
  cp "$SRC_ICONS"/*.svg "$CACHE_NORMAL/"
  cp "$SRC_ICONS"/*.svg "$CACHE_ACTIVE/"

  # 6. Reemplazar colores
  # Nota: Asumimos que el original es NEGRO (#000000).
  # Si tus iconos originales son blancos, cambia #000000 por #ffffff abajo.

  # Set Normal -> Color del texto ($foreground)
  sed -i "s/#ffffff/$foreground/g" "$CACHE_NORMAL"/*.svg

  # Set Activo -> Color Primario ($color4)
  sed -i "s/#ffffff/$color2/g" "$CACHE_ACTIVE"/*.svg

  echo "Iconos de wlogout actualizados correctamente."
) &

# --- 12. Actualizar colores Quickshell
(
  ln -sf ~/.cache/wal/qs-colors.qml ~/.config/quickshell/Colors.qml
) &

wait

log_step "Script completado. Total: $(echo "$(date +%s.%N) - $START_TIME" | bc)s"

notify-send -a "Hyprland" "Wallpaper Changed" "Theme updated successfully.\nFile: $(basename "$wallpaper")" -i "$wallpaper"
