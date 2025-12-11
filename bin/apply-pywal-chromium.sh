#!/bin/bash

# =========================================================
# SCRIPT DE TEMATIZACIÓN PYWAL PARA OMARCHY-CHROMIUM
# Solo aplica colores si Chromium ya está en ejecución.
# =========================================================

# --- Funciones de Conversión ---

# Convierte HEX a formato R,G,B (ej. 156,48,34)
hex_to_rgb_comma() {
    local hex="${1#\#}"
    local r=$(printf "%d" 0x${hex:0:2})
    local g=$(printf "%d" 0x${hex:2:2})
    local b=$(printf "%d" 0x${hex:4:2})
    echo "$r,$g,$b"
}

# Devuelve los componentes RGB por separado
hex_to_rgb_components() {
    local hex="${1#\#}"
    local r=$(printf "%d" 0x${hex:0:2})
    local g=$(printf "%d" 0x${hex:2:2})
    local b=$(printf "%d" 0x${hex:4:2})
    echo "$r $g $b"
}

# --- Configuración de Variables ---
WAL_COLORS_FILE="${HOME}/.cache/wal/colors.json"
CHROMIUM_BINARY="chromium"

# Colores de Fallback para Temas B/N (Baja Saturación)
FALLBACK_HEX="#3C83B5"
FALLBACK_RGB="60,131,181"
SATURATION_THRESHOLD=15 # Máxima diferencia permitida entre R, G, B para ser considerado escala de grises.

# Verifica la existencia del archivo de colores
if [ ! -f "$WAL_COLORS_FILE" ]; then
    echo "Error: Archivo de colores de Pywal no encontrado en $WAL_COLORS_FILE"
    exit 1
fi

# --- Comprobación de Instancia Activa ---
if pgrep -x "$CHROMIUM_BINARY" > /dev/null; then

    # --- 1. Extracción de Datos de Pywal ---
    COLOR_ACCENT_HEX=$(jq -r '.colors.color1' "$WAL_COLORS_FILE")
    SCHEME=$(jq -r '.metadata.scheme' "$WAL_COLORS_FILE")

    # --- 2. Detección de Blanco y Negro (Baja Saturación) ---
    RGB_COMPONENTS=$(hex_to_rgb_components "$COLOR_ACCENT_HEX")
    read R G B <<< "$RGB_COMPONENTS"
    
    # Calcular las diferencias absolutas entre componentes
    DIFF_RG=$(( R > G ? R - G : G - R ))
    DIFF_GB=$(( G > B ? G - B : B - G ))
    DIFF_RB=$(( R > B ? R - B : B - R ))
    
    # Aplicar Fallback si es B/N
    if [[ $DIFF_RG -le $SATURATION_THRESHOLD && $DIFF_GB -le $SATURATION_THRESHOLD && $DIFF_RB -le $SATURATION_THRESHOLD ]]; then
        COLOR_ACCENT_RGB="$FALLBACK_RGB"
        echo "Advertencia: Tema detectado como B/N (Saturación baja). Usando color de fallback: $FALLBACK_HEX."
    else
        # Si tiene color, usar el color de pywal
        COLOR_ACCENT_RGB=$(hex_to_rgb_comma "$COLOR_ACCENT_HEX")
    fi

    # --- 3. Lógica de Esquema de Color (FORZADO a 'dark') ---
    COLOR_SCHEME="dark"
    
    # --- 4. Construcción y Ejecución del Comando de Chromium ---
    
    CHROMIUM_COMMAND="$CHROMIUM_BINARY \
        --ozone-platform=wayland \
        --ozone-platform-hint=wayland \
        --enable-features=TouchpadOverscrollHistoryNavigation \
        --disable-features=WaylandWpColorManagerV1 \
        --load-extension=~/.local/share/omarchy/default/chromium/extensions/copy-url \
        --set-user-color=$COLOR_ACCENT_RGB \
        --set-color-scheme=$COLOR_SCHEME \
        --set-color-variant=vibrant \
        --refresh-platform-policy \
        --no-startup-window"

    echo "Aplicando Pywal color $COLOR_ACCENT_RGB y esquema $COLOR_SCHEME a Chromium..."
    $CHROMIUM_COMMAND &

    echo "Configuración de Chromium actualizada."
    
else
    echo "Chromium no está activo. Los colores se aplicarán en el próximo inicio."
fi
