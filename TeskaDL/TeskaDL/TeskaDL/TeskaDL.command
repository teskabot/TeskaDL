#!/bin/bash
# TeskaDL - by TESKADEV · teskadev.ar
# Doble clic en Finder. La primera vez baja lo que falte a la carpeta "bin".

cd "$(dirname "$0")" || exit 1
HERE="$(pwd)"
BIN="$HERE/bin"
OUT="$HOME/Downloads/TeskaDL"
# bin propio primero; después Homebrew por si ya tenés las herramientas instaladas
export PATH="$BIN:/opt/homebrew/bin:/usr/local/bin:$PATH"

G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; N='\033[0m'
mkdir -p "$OUT"

have() { command -v "$1" >/dev/null 2>&1; }

get_tools() {
  mkdir -p "$BIN"
  local TMP; TMP="$(mktemp -d)"
  local ARCH; ARCH="$(uname -m)"
  local FF_ARCH DENO_ZIP
  if [ "$ARCH" = "arm64" ]; then
    FF_ARCH="arm64"; DENO_ZIP="deno-aarch64-apple-darwin.zip"
  else
    FF_ARCH="amd64"; DENO_ZIP="deno-x86_64-apple-darwin.zip"
  fi

  if ! have yt-dlp; then
    echo -e "\n${G}[..] Bajando yt-dlp...${N}"
    curl -L --fail -# -o "$BIN/yt-dlp" \
      "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos" && chmod +x "$BIN/yt-dlp"
  fi

  if ! have ffmpeg; then
    echo -e "\n${G}[..] Bajando ffmpeg (es el pesado, banca un toque)...${N}"
    for f in ffmpeg ffprobe; do
      curl -L --fail -# -o "$TMP/$f.zip" \
        "https://ffmpeg.martin-riedl.de/redirect/latest/macos/$FF_ARCH/release/$f.zip" \
        && unzip -o -q "$TMP/$f.zip" -d "$BIN" && chmod +x "$BIN/$f"
    done
  fi

  if ! have deno; then
    echo -e "\n${G}[..] Bajando Deno...${N}"
    curl -L --fail -# -o "$TMP/deno.zip" \
      "https://github.com/denoland/deno/releases/latest/download/$DENO_ZIP" \
      && unzip -o -q "$TMP/deno.zip" -d "$BIN" && chmod +x "$BIN/deno"
  fi

  # Por las dudas, que Gatekeeper no se ponga denso con los binarios
  xattr -dr com.apple.quarantine "$BIN" 2>/dev/null
  rm -rf "$TMP"
}

# --- Primera vez: chequeo y descarga ---
MISSING=()
for t in yt-dlp ffmpeg deno; do have "$t" || MISSING+=("$t"); done
if [ ${#MISSING[@]} -gt 0 ]; then
  echo -e "${Y}"
  echo "  ¿Primera vez? Faltan: ${MISSING[*]}"
  echo "  Los bajo a la carpeta \"bin\" de TeskaDL (unos 200 MB, una sola vez)."
  echo "  No se instala nada en tu sistema."
  echo -e "${N}"
  read -r -p "> ¿Los descargo? [S/N]: " ANS
  if [[ ! "$ANS" =~ ^[sS]$ ]]; then
    echo -e "${R}[X] Sin herramientas no hay magia. Chau.${N}"; read -r -p "Enter para salir..."; exit 1
  fi
  get_tools
  for t in yt-dlp ffmpeg deno; do
    if ! have "$t"; then
      echo -e "\n${R}[X] Algo falló bajando $t. Revisá tu conexión y volvé a abrir TeskaDL.${N}"
      read -r -p "Enter para salir..."; exit 1
    fi
  done
  echo -e "\n${G}[OK] Todo listo. A darle.${N}"; sleep 1
fi

TPL="$OUT/%(title)s.%(ext)s"

while true; do
  clear
  echo -e "${G}"
  cat <<'EOF'
 ████████╗███████╗███████╗██╗  ██╗ █████╗     ██████╗ ██╗
 ╚══██╔══╝██╔════╝██╔════╝██║ ██╔╝██╔══██╗    ██╔══██╗██║
    ██║   █████╗  ███████╗█████╔╝ ███████║    ██║  ██║██║
    ██║   ██╔══╝  ╚════██║██╔═██╗ ██╔══██║    ██║  ██║██║
    ██║   ███████╗███████║██║  ██╗██║  ██║    ██████╔╝███████╗
    ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═════╝ ╚══════╝
 ------------------------------------------------- teskadev.ar

  [1] Audio MP3 (320, con tapa y metadata)
  [2] Audio WAV (para el estudio)
  [3] Video MP4 - mejor calidad
  [4] Video MP4 - máx 1080p
  [5] Playlist completa en MP3
  [U] Actualizar yt-dlp
  [A] Abrir carpeta de descargas
  [0] Salir
EOF
  echo -e "${N}"
  read -r -p "> Elegí una opción: " OPT

  case "$OPT" in
    0) exit 0 ;;
    [uU])
      if [ -x "$BIN/yt-dlp" ]; then "$BIN/yt-dlp" -U
      elif have brew; then brew upgrade yt-dlp
      else yt-dlp -U; fi
      read -r -p "Enter para volver..."; continue ;;
    [aA]) open "$OUT"; continue ;;
    [1-5]) ;;
    *) echo -e "${R}[X] Opción inválida.${N}"; sleep 1; continue ;;
  esac

  read -r -p "> Pegá la URL: " URL
  if [ -z "$URL" ]; then
    echo -e "${R}[X] No pegaste nada, crack.${N}"; sleep 1; continue
  fi

  case "$OPT" in
    1) yt-dlp --no-playlist -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -o "$TPL" "$URL" ;;
    2) yt-dlp --no-playlist -x --audio-format wav -o "$TPL" "$URL" ;;
    3) yt-dlp --no-playlist -S "res,ext:mp4:m4a" --merge-output-format mp4 -o "$TPL" "$URL" ;;
    4) yt-dlp --no-playlist -S "res:1080,ext:mp4:m4a" --merge-output-format mp4 -o "$TPL" "$URL" ;;
    5) yt-dlp --yes-playlist -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata \
         -o "$OUT/%(playlist)s/%(playlist_index)02d - %(title)s.%(ext)s" "$URL" ;;
  esac

  echo -e "\n${G}[OK] Listo. Todo quedó en: $OUT${N}"
  read -r -p "Enter para volver al menú..."
done
