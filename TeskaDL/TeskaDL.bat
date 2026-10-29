@echo off
chcp 65001 >nul
color 0A
title TeskaDL - by TESKADEV
setlocal

set "OUT=%USERPROFILE%\Downloads\TeskaDL"
if not exist "%OUT%" mkdir "%OUT%"

:: --- Chequeo de dependencias ---
where yt-dlp >nul 2>&1 || (
  echo [X] No encuentro yt-dlp. Instalalo con:  winget install yt-dlp.yt-dlp
  pause & exit /b
)
where ffmpeg >nul 2>&1 || echo [!] Falta ffmpeg ^(winget install Gyan.FFmpeg^). Sin el, MP3/WAV/MP4 no van a andar bien.
where deno   >nul 2>&1 || echo [!] Falta Deno ^(winget install DenoLand.Deno^). YouTube puede fallar sin el.

:MENU
echo.
echo  ████████╗███████╗███████╗██╗  ██╗ █████╗     ██████╗ ██╗
echo  ╚══██╔══╝██╔════╝██╔════╝██║ ██╔╝██╔══██╗    ██╔══██╗██║
echo     ██║   █████╗  ███████╗█████╔╝ ███████║    ██║  ██║██║
echo     ██║   ██╔══╝  ╚════██║██╔═██╗ ██╔══██║    ██║  ██║██║
echo     ██║   ███████╗███████║██║  ██╗██║  ██║    ██████╔╝███████╗
echo     ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═════╝ ╚══════╝
echo  ------------------------------------------------- teskadev.ar
echo.
echo   [1] Audio MP3 (320, con tapa y metadata)
echo   [2] Audio WAV (para el estudio)
echo   [3] Video MP4 - mejor calidad
echo   [4] Video MP4 - max 1080p
echo   [5] Playlist completa en MP3
echo   [U] Actualizar yt-dlp
echo   [A] Abrir carpeta de descargas
echo   [0] Salir
echo.
set "OPT="
set /p "OPT=> Elegi una opcion: "

if /i "%OPT%"=="0" exit /b
if /i "%OPT%"=="U" ( winget upgrade yt-dlp.yt-dlp & goto MENU )
if /i "%OPT%"=="A" ( start "" "%OUT%" & goto MENU )

set "URL="
set /p "URL=> Pega la URL: "
if "%URL%"=="" ( echo [X] No pegaste nada, crack. & goto MENU )

set "TPL=%OUT%\%%(title)s.%%(ext)s"

if "%OPT%"=="1" yt-dlp --no-playlist -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -o "%TPL%" "%URL%"
if "%OPT%"=="2" yt-dlp --no-playlist -x --audio-format wav -o "%TPL%" "%URL%"
if "%OPT%"=="3" yt-dlp --no-playlist -S "res,ext:mp4:m4a" --merge-output-format mp4 -o "%TPL%" "%URL%"
if "%OPT%"=="4" yt-dlp --no-playlist -S "res:1080,ext:mp4:m4a" --merge-output-format mp4 -o "%TPL%" "%URL%"
if "%OPT%"=="5" yt-dlp --yes-playlist -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -o "%OUT%\%%(playlist)s\%%(playlist_index)02d - %%(title)s.%%(ext)s" "%URL%"

echo.
echo [OK] Listo. Todo quedo en: %OUT%
goto MENU
