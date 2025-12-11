#!/bin/bash

# Este script actualiza los colores de Pywal en todo el sistema.
# El argumento $1 es la ruta de la imagen que pasa Waypaper.

# Ruta al ejecutable de wal (necesaria para el entorno Hyprland)
# (Asegúrate de que /home/bruno/ sea tu nombre de usuario correcto)
WAL_PATH="/home/bruno/.local/bin/wal"

# --- 1. Generar Colores y Archivos de Cache ---
$WAL_PATH -i "$1" -n

# --- 2. Recargar Componentes ---

# Recargar Waybar (Recarga CSS suave para evitar saltos)
killall -SIGUSR2 waybar

# Recargar SwayNC (Recarga CSS/Config - Usamos SIGUSR1 para estabilidad)
killall -SIGUSR1 swaync

# Recargar Hyprland (Bordes de ventana)
hyprctl reload