#!/bin/bash

# Directorios de origen y destino
SOURCE="$HOME"
DEST="$HOME/hyprland-dotfiles-backup"

echo "📦 Iniciando respaldo FINAL (Con SDDM de sistema)..."

# 1. Copiar configuración de ZSH
echo "--> Copiando ZSH..."
cp "$SOURCE/.zshrc" "$DEST/" 2>/dev/null
cp "$SOURCE/.p10k.zsh" "$DEST/" 2>/dev/null

# 2. Copiar Wallpapers
echo "--> Copiando Wallpapers..."
mkdir -p "$DEST/Wallpapers"
if [ -d "$SOURCE/Wallpapers" ]; then
  cp -R "$SOURCE/Wallpapers/" "$DEST/Wallpapers/"
else
  echo "   ⚠️ No encontré carpeta ~/Wallpapers, saltando..."
fi

# 3. Copiar Scripts personales (.local/bin)
echo "--> Copiando binarios locales..."
mkdir -p "$DEST/.local/bin"
if [ -d "$SOURCE/.local/bin" ]; then
  cp -R "$SOURCE/.local/bin/" "$DEST/.local/bin/"
else
  echo "   ⚠️ No encontré ~/.local/bin, saltando..."
fi

# 4. Copiar carpetas .config clave
echo "--> Copiando configs (.config)..."
mkdir -p "$DEST/.config"

carpetas_clave=("hypr" "waybar" "kitty" "alacritty" "rofi" "dunst" "nvim" "ranger" "neofetch" "fish" "zsh")

for carpeta in "${carpetas_clave[@]}"; do
  if [ -d "$SOURCE/.config/$carpeta" ]; then
    echo "   -> Respaldando: $carpeta"
    rm -rf "$DEST/.config/$carpeta"
    cp -R "$SOURCE/.config/$carpeta" "$DEST/.config/"
  fi
done

# 5. SECCIÓN SDDM (Ruta de sistema)
echo "--> Copiando Theme SDDM (Sugar Candy)..."
mkdir -p "$DEST/sddm-themes"

# Ruta absoluta del sistema donde se instalan los temas
RUTA_SISTEMA="/usr/share/sddm/themes/sugar-candy"

if [ -d "$RUTA_SISTEMA" ]; then
  echo "   -> Encontrado en sistema. Copiando..."
  # Borramos la copia anterior en el backup para que esté limpia
  rm -rf "$DEST/sddm-themes/sugar-candy"

  # Copiamos recursivamente
  cp -R "$RUTA_SISTEMA" "$DEST/sddm-themes/"

  echo "   ✅ SDDM copiado exitosamente."
else
  echo "   ❌ ERROR CRÍTICO: No encontré la carpeta '$RUTA_SISTEMA'"
  echo "      Verifica si el nombre de la carpeta es exactamente 'sugar-candy' o tiene otro nombre."
fi

echo "✅ ¡Respaldo completado! Listo para git push."
