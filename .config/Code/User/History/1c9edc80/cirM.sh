#!/bin/bash

# Nombre del proceso (tal como aparece en tu pubspec.yaml, suele ser spotify_widget)
APP_NAME="spotify_widget"

# Ruta exacta al ejecutable
APP_PATH="$HOME/.config/waybar/scripts/spotify_flutter/spotify_widget"

if pgrep -x "$APP_NAME" > /dev/null
then
    # Si está abierto, lo cerramos
    pkill -x "$APP_NAME"
else
    # Si está cerrado, lo abrimos en segundo plano
    "$APP_PATH" &
fi