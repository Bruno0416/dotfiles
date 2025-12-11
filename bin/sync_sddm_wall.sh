#!/bin/bash

# 1. Ruta de destino (Asegúrate que 'background.png' sea el nombre correcto en la carpeta maldives)
DESTINO="/usr/share/sddm/themes/sugar-candy/Backgrounds/Mountain.jpg"

# 2. Obtener la ruta cruda desde Waypaper
RAW_PATH=$(grep "wallpaper =" ~/.config/waypaper/config.ini | cut -d "=" -f 2 | xargs)

# 3. CORRECCIÓN: Reemplazar el símbolo '~' por la ruta real ($HOME)
# Esto cambia "~/Wallpapers" por "/home/bruno/Wallpapers"
WALLPAPER="${RAW_PATH/#\~/$HOME}"

# 4. Copiar y reemplazar
if [ -f "$WALLPAPER" ]; then
    cp "$WALLPAPER" "$DESTINO"
    echo "¡Éxito! Fondo copiado de:"
    echo "$WALLPAPER" 
    echo "a:"
    echo "$DESTINO"
else
    echo "Error: Sigo sin encontrar el archivo en: $WALLPAPER"
fi
