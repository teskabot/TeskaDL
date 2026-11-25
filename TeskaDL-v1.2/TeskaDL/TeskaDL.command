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

# ¿La herramienta existe Y arranca? (que exista no alcanza: macOS puede bloquearla)
ver_flag() { case "$1" in ffmpeg|ffprobe) echo "-version" ;; *) echo "--version" ;; esac; }
ok() { command -v "$1" >/dev/null 2>&1 && "$1" "$(ver_flag "$1")" >/dev/null 2>&1; }

# Apple Silicon real (aunque Terminal corra bajo Rosetta)
if [ "$(sysctl -n hw.optional.arm64 2>/dev/null)" = "1" ]; then
  FF_ARCH="arm64"; DENO_ZIP="deno-aarch64-apple-darwin.zip"
else
  FF_ARCH="amd64"; DENO_ZIP="deno-x86_64-apple-darwin.zip"
fi

# Destrabar binarios: sacar cuarentena y firmarlos ad-hoc (sin esto, macOS los mata en silencio)
fix_bins() {
  [ -d "$BIN" ] || return
  xattr -dr com.apple.quarantine "$BIN" 2>/dev/null
  for f in "$BIN"/*; do
    [ -f "$f" ] && chmod +x "$f" && codesign --force -s - "$f" >/dev/null 2>&1
  done
}

get_tools() {
  mkdir -p "$BIN"
  local TMP; TMP="$(mktemp -d)"

  if ! ok yt-dlp; then
    echo -e "\n${G}[..] Bajando yt-dlp...${N}"
    rm -f "$BIN/yt-dlp"
    curl -L --fail -# -o "$BIN/yt-dlp" \
      "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos"
  fi

  if ! ok ffmpeg || ! ok ffprobe; then
    echo -e "\n${G}[..] Bajando ffmpeg (es el pesado, banca un toque)...${N}"
    for f in ffmpeg ffprobe; do
      rm -rf "$TMP/x" "$BIN/$f"; mkdir -p "$TMP/x"
      if curl -L --fail -# -o "$TMP/$f.zip" \
           "https://ffmpeg.martin-riedl.de/redirect/latest/macos/$FF_ARCH/release/$f.zip" \
         && unzip -o -q "$TMP/$f.zip" -d "$TMP/x"; then
        # el binario puede venir suelto o dentro de una subcarpeta
        found="$(find "$TMP/x" -type f -name "$f" | head -n 1)"
        [ -n "$found" ] && mv "$found" "$BIN/$f"
      fi
    done
  fi

  if ! ok deno; then
    echo -e "\n${G}[..] Bajando Deno...${N}"
    rm -f "$BIN/deno"
    curl -L --fail -# -o "$TMP/deno.zip" \
      "https://github.com/denoland/deno/releases/latest/download/$DENO_ZIP" \
      && unzip -o -q "$TMP/deno.zip" -d "$BIN"
  fi

  rm -rf "$TMP"
  echo -e "\n${G}[..] Preparando binarios para macOS (puede tardar unos segundos)...${N}"
  fix_bins
}

# Plan B para ffmpeg: Homebrew, si la persona lo tiene
brew_ffmpeg() {
  command -v brew >/dev/null 2>&1 || return 1
  read -r -p "> Tenés Homebrew. ¿Instalo ffmpeg con brew? [S/N]: " A
  [[ "$A" =~ ^[sS]$ ]] || return 1
  rm -f "$BIN/ffmpeg" "$BIN/ffprobe"
  brew install ffmpeg
}

# --- Chequeo al arrancar (también repara instalaciones rotas) ---
echo -e "${G}TeskaDL · chequeando herramientas...${N}"
# Destraba toda la carpeta, así el resto de los archivos no vuelven a pedir permiso
xattr -dr com.apple.quarantine "$HERE" 2>/dev/null
MISSING=()
for t in yt-dlp ffmpeg ffprobe deno; do ok "$t" || MISSING+=("$t"); done
if [ ${#MISSING[@]} -gt 0 ]; then
  echo -e "${Y}"
  echo "  Faltan o no arrancan: ${MISSING[*]}"
  echo "  (La primera vez es normal.)"
  echo "  Los bajo a la carpeta \"bin\" de TeskaDL (unos 200 MB, una sola vez)."
  echo "  No se instala nada en tu sistema."
  echo -e "${N}"
  read -r -p "> ¿Los descargo? [S/N]: " ANS
  if [[ ! "$ANS" =~ ^[sS]$ ]]; then
    echo -e "${R}[X] Sin herramientas no hay magia. Chau.${N}"; read -r -p "Enter para salir..."; exit 1
  fi
  get_tools
  if ! ok ffmpeg || ! ok ffprobe; then
    echo -e "\n${Y}[!] ffmpeg no arranca. Esto dice macOS:${N}"
    "$BIN/ffmpeg" -version 2>&1 | head -n 3
    brew_ffmpeg
  fi
  FAIL=0
  for t in yt-dlp ffmpeg ffprobe deno; do
    ok "$t" || { echo -e "${R}[X] $t no arranca.${N}"; FAIL=1; }
  done
  if [ "$FAIL" = 1 ]; then
    echo -e "\n${R}Mandale captura de esto a @teskadev y lo vemos.${N}"
    read -r -p "Enter para salir..."; exit 1
  fi
  echo -e "\n${G}[OK] Todo listo. A darle.${N}"; sleep 1
fi

# Le decimos a yt-dlp exactamente dónde está ffmpeg
FFLOC="$(dirname "$(command -v ffmpeg)")"
YT=(yt-dlp --ffmpeg-location "$FFLOC")
TPL="$OUT/%(title)s.%(ext)s"

# Deshace los caracteres que yt-dlp usa en los nombres de archivo en vez de : ? / etc.
# (el " se queda como está)
unfw() {
  printf '%s' "$1" | LC_ALL=C sed -e 's/：/:/g' -e 's/？/?/g' -e 's|⧸|/|g' -e 's/⧹/\\/g' \
    -e 's/＊/*/g' -e 's/＜/</g' -e 's/＞/>/g' -e 's/｜/|/g'
}

# Disco completo -> un archivo por canción, usando los capítulos del video.
# yt-dlp baja todo y lo corta en una carpeta temporal; después cada canción
# recibe su título, número de pista y álbum (yt-dlp les deja a todas el título
# del video entero) y se mueve a $OUT/<disco>.
album() {
  local FMT="$1" TMPD="$OUT/.teskadl_tmp"
  rm -rf "$TMPD"
  local EXTRA=(--add-metadata)
  [ "$FMT" = mp3 ] && EXTRA+=(--audio-quality 0 --embed-thumbnail)
  "${YT[@]}" --no-playlist -x --audio-format "$FMT" "${EXTRA[@]}" --split-chapters \
    -o "$TMPD/%(title)s.%(ext)s" \
    -o "chapter:$TMPD/tracks/%(section_number)02d - %(section_title)s.%(ext)s" "$URL" || return 1

  local full; full="$(find "$TMPD" -maxdepth 1 -type f -name "*.$FMT" | head -n 1)"
  [ -n "$full" ] || { echo -e "${R}[X] No encontré el archivo descargado.${N}"; return 1; }

  local songs=() s
  while IFS= read -r s; do songs+=("$s"); done < <(find "$TMPD/tracks" -type f -name "*.$FMT" 2>/dev/null | sort)
  if [ ${#songs[@]} -eq 0 ]; then
    mv -f "$full" "$OUT/"; rm -rf "$TMPD"
    echo -e "\n${Y}[!] Este video no tiene capítulos, así que no hay nada que separar.${N}"
    echo -e "${Y}    Te dejé el archivo entero en: $OUT${N}"
    return 0
  fi

  echo -e "\n${G}[..] Poniendo nombre y número a cada canción...${N}"
  local name album dest base n ti tot=${#songs[@]} fx="$TMPD/tracks/_fix.$FMT"
  local ID3=(); [ "$FMT" = mp3 ] && ID3=(-id3v2_version 3)
  name="$(basename "$full")"; name="${name%.*}"
  album="$(unfw "$name")"; dest="$OUT/$name"
  mkdir -p "$dest"
  for s in "${songs[@]}"; do
    base="$(basename "$s")"; base="${base%.*}"
    n="${base%% - *}"; ti="${base#* - }"
    [[ "$n" =~ ^[0-9]+$ ]] || { n=0; ti="$base"; }
    if "$FFLOC/ffmpeg" -v error -y -i "$s" -map 0 -c copy \
         -metadata "title=$(unfw "$ti")" -metadata "track=$((10#$n))/$tot" -metadata "album=$album" \
         ${ID3[@]+"${ID3[@]}"} "$fx"; then
      mv -f "$fx" "$dest/$(basename "$s")"
    else
      mv -f "$s" "$dest/"
    fi
  done
  rm -rf "$TMPD"
  echo -e "\n${G}[OK] Listo: $tot canciones en: $dest${N}"
}

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
  [6] Disco completo en MP3, separado por canción
  [7] Disco completo en WAV, separado por canción
  [U] Actualizar yt-dlp
  [A] Abrir carpeta de descargas
  [0] Salir
EOF
  echo -e "${N}"
  read -r -p "> Elegí una opción: " OPT

  case "$OPT" in
    0) exit 0 ;;
    [uU])
      if [ -x "$BIN/yt-dlp" ]; then "$BIN/yt-dlp" -U && codesign --force -s - "$BIN/yt-dlp" >/dev/null 2>&1
      elif command -v brew >/dev/null 2>&1; then brew upgrade yt-dlp
      else yt-dlp -U; fi
      read -r -p "Enter para volver..."; continue ;;
    [aA]) open "$OUT"; continue ;;
    [1-7]) ;;
    *) echo -e "${R}[X] Opción inválida.${N}"; sleep 1; continue ;;
  esac

  read -r -p "> Pegá la URL: " URL
  if [ -z "$URL" ]; then
    echo -e "${R}[X] No pegaste nada, crack.${N}"; sleep 1; continue
  fi

  case "$OPT" in
    1) "${YT[@]}" --no-playlist -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -o "$TPL" "$URL" ;;
    2) "${YT[@]}" --no-playlist -x --audio-format wav -o "$TPL" "$URL" ;;
    3) "${YT[@]}" --no-playlist -S "res,ext:mp4:m4a" --merge-output-format mp4 -o "$TPL" "$URL" ;;
    4) "${YT[@]}" --no-playlist -S "res:1080,ext:mp4:m4a" --merge-output-format mp4 -o "$TPL" "$URL" ;;
    5) "${YT[@]}" --yes-playlist -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata \
         -o "$OUT/%(playlist)s/%(playlist_index)02d - %(title)s.%(ext)s" "$URL" ;;
    6) album mp3 ;;
    7) album wav ;;
  esac
  RC=$?

  if [ $RC -eq 0 ]; then
    # 6 y 7 ya avisan solos dónde quedaron las canciones
    [[ "$OPT" == [67] ]] || echo -e "\n${G}[OK] Listo. Todo quedó en: $OUT${N}"
  else
    echo -e "\n${R}[X] Algo falló (mirá el ERROR de arriba). Probá [U] para actualizar.${N}"
  fi
  read -r -p "Enter para volver al menú..."
done
