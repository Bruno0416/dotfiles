#!/bin/bash

# Ruta al ejecutable de wal (necesaria para el entorno Hyprland)
WAL_PATH="/home/bruno/.local/bin/wal" 

# 1. Generar colores con Pywal
$WAL_PATH -i "$1" -n

# 2. Generar archivo de paleta para Gradience (usa el archivo del Paso 2)
$WAL_PATH --template ~/.cache/wal/gradience-colors.json > /tmp/gradience-palette.json

# 3. Aplicar tema de Gradience con los nuevos colores (Requiere el comando CLI)
# Nota: El CLI de Gradience es complejo de automatizar, si este paso falla, Gradience no está disponible via CLI en tu instalación.
gradience-cli apply --name 'Adw' --theme-mode 'dark' --color-scheme 'user' --palette-file /tmp/gradience-palette.json

# 4. Actualizar aplicaciones (Waybar, Hyprland, SwayNC)
killall -SIGUSR2 waybar
killall -SIGUSR1 swaync
hyprctl reload