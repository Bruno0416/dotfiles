#!/bin/bash

# --- CONFIGURACIÓN ---
THEME_NAME="sugar-candy" 

THEME_DIR="/usr/share/sddm/themes/$THEME_NAME/Backgrounds"
TARGET_FILE="current.jpg"
NEW_WALLPAPER="$1"

# --- VERIFICACIONES ---
if [ -z "$NEW_WALLPAPER" ]; then
    echo "Error: No se pasó ninguna imagen."
    exit 1
fi

if [ ! -d "$THEME_DIR" ]; then
    echo "Error: No encuentro la carpeta del tema: $THEME_DIR"
    exit 1
fi

# --- EJECUCIÓN ---
cp "$NEW_WALLPAPER" "$THEME_DIR/$TARGET_FILE"
chmod 644 "$THEME_DIR/$TARGET_FILE"

echo "Fondo SDDM actualizado correctamente."
