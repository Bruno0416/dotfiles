#!/bin/bash
# Selector de Audio para Fedora/Wireplumber con estilo Pywal

# Ruta a tu tema (Asegúrate de que este archivo existe)
ROFI_THEME="$HOME/.config/rofi/pywal-theme.rasi"

# Iconos
ICON_OUTPUT="  Salida"
ICON_INPUT="  Entrada"

# 1. Menú Principal: Elegir entre Salida o Entrada
# Usamos printf para evitar problemas con echo
opcion=$(printf "$ICON_OUTPUT\n$ICON_INPUT" | rofi -dmenu -p "Configurar Audio" -theme "$ROFI_THEME" -lines 2)

# Si el usuario cancela (ESC), salimos
if [ -z "$opcion" ]; then
    exit 0
fi

# Función para limpiar la salida de wpctl y mostrarla en Rofi
# Elimina los caracteres de árbol (│ └ ─) y espacios iniciales para dejar limpia la lista
seleccionar_dispositivo() {
    TIPO=$1 # "Sinks" o "Sources"
    TITULO=$2
    
    # Magia de parsing:
    # 1. wpctl status
    # 2. awk extrae el bloque entre el TIPO y la siguiente sección
    # 3. grep busca líneas que tengan un número seguido de punto (ej: " 45.")
    # 4. sed elimina los caracteres gráficos del árbol para limpiar la vista
    DISPOSITIVO=$(wpctl status | \
                  awk "/$TIPO:/,/Filters:/" | \
                  grep -E "[0-9]+\." | \
                  sed 's/[│└├─]*//g' | \
                  sed 's/^[ \t]*//' | \
                  rofi -dmenu -p "$TITULO" -theme "$ROFI_THEME" -width 600)
    
    # Si seleccionó algo, extraemos el ID (el primer número antes del punto)
    if [ -n "$DISPOSITIVO" ]; then
        ID=$(echo "$DISPOSITIVO" | awk '{print $1}' | sed 's/\.//')
        wpctl set-default "$ID"
        notify-send "Audio Cambiado" "Ahora usando: $DISPOSITIVO"
    fi
}

case "$opcion" in
    "$ICON_OUTPUT")
        seleccionar_dispositivo "Sinks" "Seleccionar Parlantes"
        ;;
    "$ICON_INPUT")
        seleccionar_dispositivo "Sources" "Seleccionar Micrófono"
        ;;
esac
