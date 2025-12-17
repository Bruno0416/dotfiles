#!/bin/bash

# ==========================================
# SCRIPT DE RESTAURACIÓN DE DOTFILES (ARCH)
# ==========================================

# Directorio actual (donde clonaste el repo)
SOURCE_DIR="$(pwd)"

echo "🚀 Iniciando restauración de entorno..."

# --- 1. PREGUNTA DE INSTALACIÓN DE PAQUETES ---
read -p "¿Quieres instalar los paquetes base necesarios (hyprland, kitty, sddm, etc)? (s/n): " instalar_pkg
if [[ "$instalar_pkg" == "s" || "$instalar_pkg" == "S" ]]; then
  echo "📦 Instalando paquetes con pacman..."
  # Lista de paquetes comunes para tu setup (Ajusta según necesites)
  # qt5-* son necesarios para que el tema Sugar Candy funcione bien
  sudo pacman -S --needed \
    hyprland waybar kitty alacritty rofi dunst \
    neovim ranger neofetch zsh git \
    sddm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg \
    ttf-jetbrains-mono-nerd noto-fonts-emoji \
    dolphin thunar # Exploradores de archivos opcionales
fi

# --- 2. RESTAURAR ARCHIVOS DE USUARIO ---
echo "📂 Restaurando configuraciones de usuario..."

# Crear directorios base si no existen
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/Wallpapers"

# Copiar .config
echo "   -> Copiando carpetas .config..."
# Usamos cp -rT para fusionar contenidos sin borrar carpetas existentes si ya hay algo
cp -rT "$SOURCE_DIR/.config" "$HOME/.config"

# Copiar Wallpapers
echo "   -> Copiando Wallpapers..."
cp -r "$SOURCE_DIR/Wallpapers/"* "$HOME/Wallpapers/" 2>/dev/null

# Copiar Binarios Locales
echo "   -> Copiando scripts en .local/bin..."
cp -r "$SOURCE_DIR/.local/bin/"* "$HOME/.local/bin/" 2>/dev/null
# Dar permisos de ejecución
chmod +x "$HOME/.local/bin/"* 2>/dev/null

# Copiar ZSH
echo "   -> Copiando .zshrc y p10k..."
cp "$SOURCE_DIR/.zshrc" "$HOME/"
cp "$SOURCE_DIR/.p10k.zsh" "$HOME/" 2>/dev/null

# --- 3. RESTAURAR THEME SDDM (REQUIERE SUDO) ---
echo "🔐 Restaurando Theme SDDM (Sugar Candy)..."

if [ -d "$SOURCE_DIR/sddm-themes/sugar-candy" ]; then
  # Crear directorio de temas del sistema
  sudo mkdir -p /usr/share/sddm/themes

  # Copiar el tema
  echo "   -> Copiando tema a /usr/share/sddm/themes/..."
  sudo cp -R "$SOURCE_DIR/sddm-themes/sugar-candy" /usr/share/sddm/themes/

  # --- 4. ACTIVAR EL TEMA EN SDDM ---
  echo "⚙️  Configurando SDDM para usar sugar-candy..."

  # Crear carpeta de configuración si no existe
  sudo mkdir -p /etc/sddm.conf.d

  # Crear archivo de configuración que fuerza el tema
  # Esto es mejor que editar /etc/sddm.conf directamente
  echo "[Theme]
Current=sugar-candy
" | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null

  echo "   ✅ Tema configurado y activado."
else
  echo "   ⚠️ No encontré la carpeta 'sddm-themes/sugar-candy' en el repo."
fi

# --- 5. FINALIZACIÓN ---
echo ""
echo "✨ ¡Restauración completada!"
echo "-------------------------------------"
echo "Pasos siguientes recomendados:"
echo "1. Si usas plugins de ZSH, asegúrate de instalarlos (ej: Oh My Zsh)."
echo "2. Habilita el servicio de login: sudo systemctl enable sddm"
echo "3. Reinicia tu Mac: reboot"
echo "-------------------------------------"
