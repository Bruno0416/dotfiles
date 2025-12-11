#!/bin/bash

# Leer colores de Pywal
source ~/.cache/wal/colors.sh

# SOLO generamos el archivo de colores, NO el CSS completo
cat > ~/.config/swaync/colors.css << EOF
/* Colores de Pywal - Generado automáticamente */
@define-color background ${background};
@define-color foreground ${foreground};
@define-color color0 ${color0};
@define-color color1 ${color1};
@define-color color2 ${color2};
@define-color color3 ${color3};
@define-color color4 ${color4};
@define-color color5 ${color5};
EOF

# Recargar swaync
swaync-client -rs
