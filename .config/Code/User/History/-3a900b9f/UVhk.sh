#!/bin/bash

# Leer colores de pywal
COLORS="$HOME/.cache/wal/colors.sh"

if [ ! -f "$COLORS" ]; then
    echo "⚠️  Ejecuta 'wal -i /ruta/a/imagen' primero"
    exit 1
fi

source "$COLORS"

# Crear tema completo con transparencia y blur
# Nota: La transparencia se aplica añadiendo "BF" (75% de opacidad) o "99" (60% de opacidad) al final del código hexadecimal.
cat > ~/.config/rofi/pywal-theme.rasi << THEME
* {
    background:     ${background}BF; /* Fondo principal semitransparente */
    background-alt: ${color0}99;     /* Color alternativo (más opaco) */
    foreground:     ${foreground}FF;
    selected:       ${color1}FF;
    active:         ${color2}FF;
    urgent:         ${color3}FF;
    transparent:    #00000000;
}

window {
    /* La ventana base (visible solo si hay border, padding, o si no hay compositor) */
    transparency: "real";
    background-color: @transparent;
    text-color: @foreground;
    border: 2px;             /* <--- CORRECCIÓN: Elimina el borde exterior */
    border-color: @selected;
    border-radius: 16px;
    width: 600px;
    location: center;
    anchor: center;
}

mainbox {
    background-color: @background; /* Usa el color con transparencia */
    children: [ inputbar, listview, mode-switcher ];
    spacing: 15px;
    padding: 25px;
    border-radius: 16px;
}

prompt {
    enabled: false; /* El prompt está deshabilitado */
}

/* Sección de textbox-prompt-colon: NO NECESARIA si el prompt está deshabilitado y se elimina de inputbar */
/* Eliminado para mayor limpieza */

entry { 
    border: 0px; 
    background-color: @background-alt;
    text-color: @foreground;
    placeholder-color: @foreground;
    expand: true;
    horizontal-align: 0;
    placeholder: "Search...";
    blink: true;
    padding: 10px 14px;
    border-radius: 10px; /* <--- CORRECCIÓN: Se eliminó la 's' extra */
}

inputbar {
    /* <--- CORRECCIÓN: Sólo lista 'entry' para eliminar el rectángulo del prompt */
    children: [ entry ]; 
    background-color: @transparent; 
    text-color: @foreground;
    expand: false;
    border-radius: 10px;
    margin: 0px 0px 10px 0px;
    padding: 0px;
    spacing: 0px;
}

listview {
    background-color: @transparent;
    columns: 1;
    lines: 7;
    spacing: 6px;
    cycle: true;
    dynamic: true;
    layout: vertical;
    padding: 8px 0px;
}

element {
    background-color: @transparent;
    text-color: @foreground;
    orientation: horizontal;
    border-radius: 10px;
    padding: 12px 16px;
    spacing: 12px;
}

/* ... (el resto de las secciones 'element' y 'button' permanecen iguales) ... */

element-icon {
    background-color: @transparent;
    size: 32px;
    border: 0;
}

element-text {
    background-color: @transparent;
    text-color: inherit;
    expand: true;
    horizontal-align: 0;
    vertical-align: 0.5;
}

element normal.normal {
    background-color: @transparent;
    text-color: @foreground;
}

element alternate.normal {
    background-color: @transparent;
    text-color: @foreground;
}

element selected.normal {
    background-color: @selected;
    text-color: @background;
    border-radius: 10px;
}

element normal.urgent,
element alternate.urgent,
element selected.urgent {
    background-color: @urgent;
    text-color: @background;
    border-radius: 10px;
}

element normal.active,
element alternate.active,
element selected.active {
    background-color: @active;
    text-color: @background;
    border-radius: 10px;
}

mode-switcher {
    spacing: 10;
    background-color: @transparent;
    border-radius: 10px;
    margin: 10px 0px 0px 0px;
}

button {
    padding: 12px;
    background-color: @background-alt;
    text-color: @foreground;
 
    border-radius: 10px;
}

button selected {
    background-color: @selected;
    text-color: @background;
    
  
    border-radius: 10px;
}

message {
    background-color: @background-alt;
    margin: 0px;
    padding: 12px;
    border-radius: 10px;
}

textbox {
    padding: 10px;
    border-radius: 10px;
    background-color: @transparent;
    text-color: @foreground;
    vertical-align: 0.5;
    horizontal-align: 0.5;
}

error-message {
    padding: 15px;
    border-radius: 10px;
    background-color: @background;
    text-color: @foreground;
}
THEME

echo "✅ Tema de Rofi con blur generado correctamente"