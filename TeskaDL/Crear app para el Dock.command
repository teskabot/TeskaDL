#!/bin/bash
# TeskaDL - Crea TeskaDL.app en ~/Applications para poder ponerla en el Dock.
# Si movés la carpeta TeskaDL, volvé a correr este archivo.

cd "$(dirname "$0")" || exit 1
HERE="$(pwd)"
CMD="$HERE/TeskaDL.command"
APP="$HOME/Applications/TeskaDL.app"
G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; N='\033[0m'

if [ ! -f "$CMD" ]; then
  echo -e "${R}[X] No encuentro TeskaDL.command al lado de este archivo.${N}"
  read -r -p "Enter para salir..."; exit 1
fi
chmod +x "$CMD"
xattr -dr com.apple.quarantine "$HERE" 2>/dev/null

# --- La app: abre Terminal y corre TeskaDL.command ---
mkdir -p "$HOME/Applications"
rm -rf "$APP"
osacompile -o "$APP" \
  -e 'on run' \
  -e "  set cmdPath to \"$CMD\"" \
  -e '  tell application "Terminal"' \
  -e '    activate' \
  -e '    do script quoted form of cmdPath' \
  -e '  end tell' \
  -e 'end run' || { echo -e "${R}[X] No pude crear la app.${N}"; read -r -p "Enter para salir..."; exit 1; }

# --- Ícono: busca el primer .ico/.png/.icns de la carpeta ---
ICON="$(find "$HERE" -maxdepth 1 -type f \( -iname '*.icns' -o -iname '*.ico' -o -iname '*.png' \) | head -n 1)"
if [ -n "$ICON" ]; then
  TMP="$(mktemp -d)"
  if sips -s format png -z 256 256 "$ICON" --out "$TMP/icon.png" >/dev/null 2>&1 \
     && sips -s format icns "$TMP/icon.png" --out "$APP/Contents/Resources/applet.icns" >/dev/null 2>&1; then
    echo -e "${G}[OK] Ícono aplicado: $(basename "$ICON")${N}"
  else
    echo -e "${Y}[!] No pude convertir $(basename "$ICON"). La app queda con el ícono por defecto.${N}"
  fi
  rm -rf "$TMP"
  touch "$APP"
fi

echo
echo -e "${G}[OK] TeskaDL.app creada en tu carpeta Aplicaciones personal.${N}"
echo "     Arrastrala al Dock y listo."
echo "     La primera vez macOS te pide permiso para controlar Terminal: aceptá."
echo
open -R "$APP"
read -r -p "Enter para cerrar..."
