import json
import os

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

# Leer colores de Pywal
home = os.path.expanduser("~")
with open(f"{home}/.cache/wal/colors.json") as f:
    data = json.load(f)
    c = data['colors']

# Definir el tema con mejor contraste
manifest = {
    "manifest_version": 3,
    "version": "1.0",
    "name": "Pywal Theme",
    "description": "Tema generado automáticamente por Pywal",
    "theme": {
        "colors": {
            # Marco y barra de herramientas (Fondo oscuro)
            "frame": hex_to_rgb(c['color0']),
            "frame_inactive": hex_to_rgb(c['color0']),
            "toolbar": hex_to_rgb(c['color0']),
            
            # Pestañas
            "tab_text": hex_to_rgb(c['color7']),           # Texto pestaña activa (Claro)
            "tab_background_text": hex_to_rgb(c['color8']), # Texto pestaña inactiva (Grisáceo)
            
            # Fondo de nueva pestaña
            "ntp_background": hex_to_rgb(c['color0']),
            "ntp_text": hex_to_rgb(c['color7']),
            
            # Barra de búsqueda (Omnibox) - Usamos color8 para que resalte sobre el fondo
            "omnibox_background": hex_to_rgb(c['color8']), 
            "omnibox_text": hex_to_rgb(c['color15']),       # Texto blanco brillante
            
            # Botones
            "button_background": hex_to_rgb(c['color0'])
        },
        "tints": {
            "buttons": [0.3, 0.5, 0.5]
        }
    }
}

# Guardar
output_dir = f"{home}/.local/share/pywal-chrome/theme"
os.makedirs(output_dir, exist_ok=True)

with open(f"{output_dir}/manifest.json", "w") as f:
    json.dump(manifest, f, indent=4)

print("Tema actualizado en:", output_dir)