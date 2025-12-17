#!/bin/bash

# Leer colores de pywal
source ~/.cache/wal/colors.sh

# Generar CSS para quickCSS
cat >/tmp/vencord-pywal.css <<EOF
/* ============================================
   THEME PYWAL PARA VENCORD - AUTO-GENERADO
   $(date)
   ============================================ */

:root {
    /* ===== COLORES BASE ===== */
    --brand-experiment: ${color4} !important;
    --brand-experiment-hover: ${color5} !important;
    
    /* ===== BACKGROUNDS ===== */
    --background-primary: ${background} !important;
    --background-secondary: ${color0} !important;
    --background-secondary-alt: ${color8} !important;
    --background-tertiary: ${color0} !important;
    --background-accent: ${color4} !important;
    --background-floating: ${background} !important;
    --background-mobile-primary: ${background} !important;
    --background-mobile-secondary: ${color0} !important;
    --background-modifier-hover: ${color0}40 !important;
    --background-modifier-active: ${color4}40 !important;
    --background-modifier-selected: ${color4}60 !important;
    --background-modifier-accent: ${color4}80 !important;
    
    /* ===== TEXTO ===== */
    --text-normal: ${foreground} !important;
    --text-muted: ${color7} !important;
    --text-link: ${color6} !important;
    --header-primary: ${foreground} !important;
    --header-secondary: ${color7} !important;
    
    /* ===== INTERACTIVOS ===== */
    --interactive-normal: ${color7} !important;
    --interactive-hover: ${foreground} !important;
    --interactive-active: ${color2} !important;
    --interactive-muted: ${color8} !important;
    
    /* ===== CANALES Y CHAT ===== */
    --channels-default: ${color7} !important;
    --channel-text-area-placeholder: ${color4} !important;
    --channeltextarea-background: ${color0} !important;
    
    /* ===== SCROLLBAR ===== */
    --scrollbar-thin-thumb: ${color4} !important;
    --scrollbar-thin-track: transparent !important;
    --scrollbar-auto-thumb: ${color4} !important;
    --scrollbar-auto-track: ${color0} !important;
}
EOF

echo "✓ CSS generado en /tmp/vencord-pywal.css"
echo "Copia el contenido y pégalo en tu quickCSS de Vencord"
cat /tmp/vencord-pywal.css
