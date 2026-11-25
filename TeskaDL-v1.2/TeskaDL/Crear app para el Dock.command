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
chmod +x "$HERE"/*.command
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

# --- Ícono: busca .icns, .png o .ico en la carpeta (en ese orden) ---
ICON=""
for ext in icns png ico; do
  ICON="$(find "$HERE" -maxdepth 1 -type f -iname "*.$ext" | head -n 1)"
  [ -n "$ICON" ] && break
done

if [ -n "$ICON" ]; then
  TMP="$(mktemp -d)"
  SET="$TMP/icon.iconset"; mkdir -p "$SET"
  RES="$APP/Contents/Resources"
  ICNS_OK=0

  if [[ "$ICON" =~ \.[iI][cC][nN][sS]$ ]]; then
    cp "$ICON" "$RES/applet.icns" && ICNS_OK=1
  elif sips -s format png -Z 256 "$ICON" --out "$TMP/base.png" >/dev/null 2>&1; then
    # Armamos el iconset con todos los tamaños y lo compilamos con iconutil
    for s in 16 32 128 256; do
      sips -z $s $s "$TMP/base.png" --out "$SET/icon_${s}x${s}.png" >/dev/null 2>&1
    done
    sips -z 32 32   "$TMP/base.png" --out "$SET/icon_16x16@2x.png"   >/dev/null 2>&1
    sips -z 64 64   "$TMP/base.png" --out "$SET/icon_32x32@2x.png"   >/dev/null 2>&1
    sips -z 256 256 "$TMP/base.png" --out "$SET/icon_128x128@2x.png" >/dev/null 2>&1
    iconutil -c icns "$SET" -o "$RES/applet.icns" >/dev/null 2>&1 && ICNS_OK=1
  fi

  if [ "$ICNS_OK" = 1 ]; then
    # macOS nuevo: osacompile mete su propio ícono en Assets.car y le gana al nuestro. Afuera.
    rm -f "$RES/Assets.car"
    /usr/libexec/PlistBuddy -c "Delete :CFBundleIconName" "$APP/Contents/Info.plist" >/dev/null 2>&1
    /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile applet" "$APP/Contents/Info.plist" >/dev/null 2>&1 \
      || /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string applet" "$APP/Contents/Info.plist" >/dev/null 2>&1
    echo -e "${G}[OK] Ícono aplicado: $(basename "$ICON")${N}"
  else
    echo -e "${Y}[!] No pude convertir $(basename "$ICON"). Probá poniendo un PNG cuadrado en la carpeta.${N}"
  fi
  rm -rf "$TMP"
fi

# Re-firmar (tocamos la app, la firma vieja ya no vale) y avisarle a Finder/Dock
codesign --force --deep -s - "$APP" >/dev/null 2>&1
touch "$APP"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP" >/dev/null 2>&1

echo
echo -e "${G}[OK] TeskaDL.app creada en tu carpeta Aplicaciones personal.${N}"
echo "     Arrastrala al Dock y listo. Si ya estaba en el Dock, sacala y volvé a ponerla."
echo "     La primera vez macOS te pide permiso para controlar Terminal: aceptá."
echo
open -R "$APP"
read -r -p "Enter para cerrar..."
