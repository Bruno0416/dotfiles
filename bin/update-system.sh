#!/bin/bash
# --- CONFIGURACIÓN ---
LOG="/tmp/waypaper_debug.log"
wallpaper="$1"
WAL_PATH="wal"

# --- CONFIGURACIÓN DE RUTAS (Personalizadas) ---
# Centralizamos las rutas aquí por si cambian en el futuro
SDDM_SCRIPT="/home/bruno/.local/bin/update-sddm-bg.sh"
ROFI_SCRIPT="/home/bruno/.config/rofi/generate-theme.sh"
SWAYNC_SCRIPT="/home/bruno/.config/swaync/generate-colors.sh"
CHROMIUM_SCRIPT="/home/bruno/.local/bin/apply-pywal-chromium.sh"
VSCODE_THEME_DEST="/home/bruno/.vscode/extensions/dlasagno.wal-theme-1.2.0/themes/wal.json"
WAL_THEME_SOURCE="/home/bruno/.cache/wal/vstheme.json"

# --- FUNCIÓN DE LOGGING Y TIMER ---
START_TIME=$(date +%s.%N)
log_step() {
  local message="$1"
  local now=$(date +%s.%N)
  # Usamos bc para calcular el tiempo transcurrido
  local elapsed=$(echo "$now - $START_TIME" | bc)
  echo "[T+${elapsed}s] $message" >>"$LOG"
}

# Reiniciar Log
echo "------------------------------------------------" >"$LOG"
echo "Iniciando script a las: $(date)" >>"$LOG"
log_step "Script iniciado. Wallpaper: $1"

# --- 1. GENERACIÓN DE COLORES (CRÍTICO - BLOQUEANTE) ---
# Esto debe ocurrir antes que nada para que el resto de scripts lean los colores nuevos
log_step "[Pywal] Iniciando generación de colores..."
$WAL_PATH -i "$wallpaper" -n >>"$LOG" 2>&1
log_step "[Pywal] Colores generados."

# Matugen (Generador de temas GTK)
if command -v matugen &>/dev/null; then
  log_step "[Matugen] Iniciando generación..."
  matugen image "$wallpaper" >>"$LOG" 2>&1

  # Inyección CSS
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

# --- 2. ENLACES Y SISTEMA (RÁPIDO) ---
ln -sf "$wallpaper" /home/bruno/.cache/current_wallpaper

# --- 3. EJECUCIÓN PARALELA (OPTIMIZACIÓN MAYOR) ---
# Todo lo que está aquí abajo corre al mismo tiempo
log_step "[Parallel] Lanzando tareas en segundo plano..."

# (A) SDDM (Requiere permisos sudo configurados o pedirá pass en log si no se usa -n)
(
  if [ -f "$SDDM_SCRIPT" ]; then
    sudo -n "$SDDM_SCRIPT" "$wallpaper" >>"$LOG" 2>&1
    log_step "[SDDM] Background actualizado."
  fi
) &

# (B) Recarga de GTK (Refresco visual instantáneo)
(
  CURRENT_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
  [ -z "$CURRENT_THEME" ] && CURRENT_THEME="Adwaita"
  gsettings set org.gnome.desktop.interface gtk-theme 'HighContrast'
  sleep 0.1
  gsettings set org.gnome.desktop.interface gtk-theme "$CURRENT_THEME"
  log_step "[GTK-Reload] Tema refrescado."
#!/bin/bash
# --- CONFIGURACIÓN ---
LOG="/tmp/waypaper_debug.log"
wallpaper="$1"
WAL_PATH="wal"

# --- CONFIGURACIÓN DE RUTAS ---
SDDM_SCRIPT="/home/bruno/.local/bin/update-sddm-bg.sh"
ROFI_SCRIPT="/home/bruno/.config/rofi/generate-theme.sh"
SWAYNC_SCRIPT="/home/bruno/.config/swaync/generate-colors.sh"
CHROMIUM_SCRIPT="/home/bruno/.local/bin/apply-pywal-chromium.sh"
VSCODE_THEME_DEST="/home/bruno/.vscode/extensions/dlasagno.wal-theme-1.2.0/themes/wal.json"
WAL_THEME_SOURCE="/home/bruno/.cache/wal/vstheme.json"

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
log_step "Script iniciado. Wallpaper: $1"

# --- 1. GENERACIÓN DE COLORES (CRÍTICO) ---
log_step "[Pywal] Iniciando generación de colores..."
$WAL_PATH -i "$wallpaper" -n >>"$LOG" 2>&1
log_step "[Pywal] Colores generados."

# Matugen (Generador de temas GTK)
if command -v matugen &>/dev/null; then
  log_step "[Matugen] Iniciando generación..."
  matugen image "$wallpaper" >>"$LOG" 2>&1
  
  # Inyección CSS
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

# --- 2. ENLACES Y SISTEMA ---
ln -sf "$wallpaper" /home/bruno/.cache/current_wallpaper

# --- 3. EJECUCIÓN PARALELA (OPTIMIZACIÓN) ---
log_step "[Parallel] Lanzando tareas en segundo plano..."

# (A) SDDM
(
  if [ -f "$SDDM_SCRIPT" ]; then
      sudo -n "$SDDM_SCRIPT" "$wallpaper" >>"$LOG" 2>&1
      log_step "[SDDM] Background actualizado."
  fi
) &

# (B) Recarga de GTK
(
  CURRENT_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
  [ -z "$CURRENT_THEME" ] && CURRENT_THEME="Adwaita"
  gsettings set org.gnome.desktop.interface gtk-theme 'HighContrast'
  sleep 0.1
  gsettings set org.gnome.desktop.interface gtk-theme "$CURRENT_THEME"
  log_step "[GTK-Reload] Tema refrescado."
) &

# (C) Componentes UI (Rofi, SwayNC, Waybar)
(
  # --- ROFI (Prioridad corregida) ---
  if [ -f "$ROFI_SCRIPT" ]; then
      chmod +x "$ROFI_SCRIPT" # Asegurar ejecución
      "$ROFI_SCRIPT" >>"$LOG" 2>&1
      if [ $? -eq 0 ]; then
          log_step "[Rofi] Tema regenerado correctamente."
      else
          log_step "[Rofi] ERROR al generar tema. Ver log arriba."
      fi
  else
      log_step "[Rofi] Script no encontrado en $ROFI_SCRIPT"
  fi

  # SwayNC
  if [ -f "$SWAYNC_SCRIPT" ]; then
      "$SWAYNC_SCRIPT" >>"$LOG" 2>&1
      killall -SIGUSR1 swaync
  fi
  
  # Waybar
  killall -SIGUSR2 waybar
  
  log_step "[UI] UI Recargada."
) &

# (D) Integraciones de Apps (VSCode, Chromium, Pywalfox)
(
  # VSCode
  if [ -f "$WAL_THEME_SOURCE" ]; then
    cp "$WAL_THEME_SOURCE" "$VSCODE_THEME_DEST"
  fi

  # Chromium
  if [ -f "$CHROMIUM_SCRIPT" ]; then
      "$CHROMIUM_SCRIPT" >>"$LOG" 2>&1
  fi
  
  # --- PYWALFOX (Firefox) ---
  if command -v pywalfox &>/dev/null; then
      pywalfox update >>"$LOG" 2>&1
      log_step "[Pywalfox] Colores de Firefox actualizados."
  fi
  
  log_step "[Apps] Aplicaciones actualizadas."
) &

# (E) Walcord - Discord
(
  if command -v walcord &>/dev/null; then
    walcord >>"$LOG" 2>&1
    log_step "[Walcord] Discord actualizado."
  fi
) &

# (F) Hyprland Reload
(
    hyprctl reload
    log_step "[Hyprland] Configuración recargada."
) &

# Esperar tareas
wait

log_step "Script completado. Total: $(echo "$(date +%s.%N) - $START_TIME" | bc)s"
notify-send -a "Hyprland" "Wallpaper Changed" "Tema actualizado en $(echo "$(date +%s.%N) - $START_TIME" | bc)s" -i "$wallpaper"
