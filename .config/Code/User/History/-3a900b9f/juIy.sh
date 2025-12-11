#!/bin/bash

# Leer colores de pywal
COLORS="$HOME/.cache/wal/colors.sh"

if [ ! -f "$COLORS" ]; then
    echo "⚠️  Ejecuta 'wal -i /ruta/a/imagen' primero"
    exit 1
fi

source "$COLORS"

# Crear tema completo con transparencia y blur
cat > ~/.config/rofi/pywal-theme.rasi << THEME
* {
    background:     ${background}BF; /* Fondo principal semitransparente */
    background-alt: ${color0}99;     /* Color alternativo */
    foreground:     ${foreground}FF;
    selected:       ${color1}FF;
    active:         ${color2}FF;
    urgent:         ${color3}FF;
    transparent:    #00000000;
}

window {
    /* CAMBIO CLAVE: El color de fondo y el borde van JUNTOS aquí */
    transparency: "real";
    background-color: @background; 
    text-color: @foreground;
    border: 2px;
    border-color: @selected;
    border-radius: 20px; /* Aumenté un poco para que se note más la curva */
    width: 600px;
    location: center;
    anchor: center;
    
    /* Importante para evitar esquinas negras en Hyprland */
    fullscreen: false;
}

mainbox {
    /* CAMBIO CLAVE: mainbox ahora es transparente para respetar la curva de window */
    background-color: @transparent; 
    children: [ inputbar, listview, mode-switcher ];
    spacing: 15px;
    padding: 25px;
    /* Quitamos el border-radius de aquí para no duplicar */
}

prompt {
    enabled: false;
}

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
    border-radius: 12px;
}

inputbar {
    children: [ entry ]; 
    background-color: @transparent; 
    text-color: @foreground;
    expand: false;
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
    border-radius: 12px;
    padding: 12px 16px;
    spacing: 12px;
}

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
    border-radius: 12px;
}

element normal.urgent,
element alternate.urgent,
element selected.urgent {
    background-color: @urgent;
    text-color: @background;
    border-radius: 12px;
}

element normal.active,
element alternate.active,
element selected.active {
    background-color: @active;
    text-color: @background;
    border-radius: 12px;
}

mode-switcher {
    spacing: 15;
    background-color: @transparent;
    margin: 0px;
}

button {
    padding: 12px;
    background-color: @background-alt;
    text-color: @foreground;
    vertical-align: 0.5;
    horizontal-align: 0.5;
    border-radius: 12px;
}

button selected {
    background-color: @selected;
    text-color: @background;
    vertical-align: 0.5;
    horizontal-align: 0.5;
    border-radius: 12px;
}

message {
    background-color: @background-alt;
    margin: 0px;
    padding: 12px;
    border-radius: 12px;
}

textbox {
    padding: 10px;
    background-color: @transparent;
    text-color: @foreground;
    vertical-align: 0.5;
    horizontal-align: 0.5;
}

error-message {
    padding: 15px;
    border-radius: 12px;
    background-color: @background;
    text-color: @foreground;
}
THEME

echo "✅ Tema de Rofi corregido (bordes suaves) generado."