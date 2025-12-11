#!/bin/bash

# 1. Generar colores (Ruta completa a wal)
/home/bruno/.local/bin/wal -i "$1" -n

# 2. Actualizar Waybar (Reinicia la barra)
killall -SIGUSR2 waybar

# 3. Recargar SwayNC (SwayNC usa SIGUSR1 para recargar config/style)
killall -SIGUSR1 swaync

# 4. Recargar Hyprland (Recarga bordes)
hyprctl reload