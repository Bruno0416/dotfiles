#!/bin/bash

PYWAL_DIR="/home/bruno/ChromiumPywal" # ¡Ajusta esta ruta si es necesario!
BROWSER_COMMAND="chromium" # O "chromium-browser", depende de tu sistema

# 1. Genera el tema actualizado
echo "🤖 Generando tema Pywal para Chromium..."
(cd "$PYWAL_DIR" && ./generate-theme.sh)

# 2. Reemplaza la señal de crash por un reinicio completo
echo "♻️ Reiniciando Chromium para aplicar el nuevo tema de políticas..."

# Intenta matar todos los procesos de Chromium de forma segura
killall $BROWSER_COMMAND

# Espera un momento para que se cierren completamente
sleep 2

# Reinicia Chromium para que cargue el tema inmediatamente con las nuevas políticas
# El ' &' es crucial para que se ejecute en segundo plano y no bloquee la terminal
$BROWSER_COMMAND &

echo "✅ Reinicio y actualización completados."
