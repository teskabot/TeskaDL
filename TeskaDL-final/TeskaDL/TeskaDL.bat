@echo off
chcp 65001 >nul
color 0A
title TeskaDL - by TESKADEV
setlocal EnableExtensions

:: --- Rutas: todo vive al lado de este .bat ---
set "HERE=%~dp0"
set "BIN=%HERE%bin"
set "OUT=%USERPROFILE%\Downloads\TeskaDL"
set "PATH=%BIN%;%PATH%"
set "CURL=%SystemRoot%\System32\curl.exe"
if not exist "%OUT%" mkdir "%OUT%"

call :CHECK
if errorlevel 1 exit /b

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
if /i "%OPT%"=="U" goto UPDATE
if /i "%OPT%"=="A" ( start "" "%OUT%" & goto MENU )
echo %OPT%| findstr /r "^[1-5]$" >nul || ( echo [X] Opcion invalida. & goto MENU )

set "URL="
set /p "URL=> Pega la URL: "
if "%URL%"=="" ( echo [X] No pegaste nada, crack. & goto MENU )

set "TPL=%OUT%\%%(title)s.%%(ext)s"

if "%OPT%"=="1" yt-dlp --no-playlist -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -o "%TPL%" "%URL%"
if "%OPT%"=="2" yt-dlp --no-playlist -x --audio-format wav -o "%TPL%" "%URL%"
if "%OPT%"=="3" yt-dlp --no-playlist -S "res,ext:mp4:m4a" --merge-output-format mp4 -o "%TPL%" "%URL%"
if "%OPT%"=="4" yt-dlp --no-playlist -S "res:1080,ext:mp4:m4a" --merge-output-format mp4 -o "%TPL%" "%URL%"
if "%OPT%"=="5" yt-dlp --yes-playlist -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -o "%OUT%\%%(playlist)s\%%(playlist_index)02d - %%(title)s.%%(ext)s" "%URL%"

if errorlevel 1 goto RUN_FAIL
echo.
echo [OK] Listo. Todo quedo en: %OUT%
goto MENU

:RUN_FAIL
echo.
echo [X] Algo fallo (mira el ERROR de arriba). Proba la opcion [U] para actualizar.
goto MENU

:UPDATE
if exist "%BIN%\yt-dlp.exe" goto UPDATE_LOCAL
winget upgrade yt-dlp.yt-dlp
goto MENU
:UPDATE_LOCAL
"%BIN%\yt-dlp.exe" -U
goto MENU

:: =====================================================================
:: Primera vez: si falta algo, lo baja a la carpeta bin (sin instalar nada)
:: Solo usa curl (o PowerShell) y PowerShell: nada de tar.
:: =====================================================================
:CHECK
set "MISSING="
where yt-dlp >nul 2>&1 || set "MISSING=1"
where ffmpeg >nul 2>&1 || set "MISSING=1"
where ffprobe >nul 2>&1 || set "MISSING=1"
where deno   >nul 2>&1 || set "MISSING=1"
if not defined MISSING exit /b 0

echo.
echo  Primera vez? Faltan herramientas: yt-dlp, ffmpeg y/o Deno.
echo  Las bajo a la carpeta "bin" de TeskaDL. Son unos 300 MB, una sola vez.
echo  No se instala nada en tu sistema ni pide permisos de administrador.
echo.
set "ANS="
set /p "ANS=> Las descargo? [S/N]: "
if /i not "%ANS%"=="S" goto CHECK_ABORT
if not exist "%BIN%" mkdir "%BIN%"

where yt-dlp >nul 2>&1 || call :GET_YTDLP
where ffmpeg >nul 2>&1 || call :GET_FFMPEG
where ffprobe >nul 2>&1 || call :GET_FFMPEG
where deno   >nul 2>&1 || call :GET_DENO

set "FAILED="
where yt-dlp >nul 2>&1 || ( echo [X] No se pudo instalar yt-dlp & set "FAILED=1" )
where ffmpeg >nul 2>&1 || ( echo [X] No se pudo instalar ffmpeg & set "FAILED=1" )
where ffprobe >nul 2>&1 || ( echo [X] No se pudo instalar ffprobe & set "FAILED=1" )
where deno   >nul 2>&1 || ( echo [X] No se pudo instalar Deno & set "FAILED=1" )
if defined FAILED goto CHECK_FAIL
echo.
echo [OK] Todo listo. A darle.
exit /b 0

:CHECK_ABORT
echo [X] Sin herramientas no hay magia. Chau.
pause
exit /b 1
:CHECK_FAIL
echo.
echo  Probablemente fue la conexion, un antivirus o un firewall.
echo  Volve a abrir TeskaDL para reintentar. Si sigue igual, bajalas a mano
echo  y copialas a esta carpeta:  %BIN%
echo    yt-dlp.exe  : github.com/yt-dlp/yt-dlp/releases
echo    ffmpeg.exe y ffprobe.exe : github.com/yt-dlp/FFmpeg-Builds/releases
echo    deno.exe    : github.com/denoland/deno/releases
pause
exit /b 1

:GET_YTDLP
echo.
echo [..] Bajando yt-dlp...
set "TZ_URL=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
set "TZ_OUT=%BIN%\yt-dlp.exe"
call :DL
if errorlevel 1 del "%TZ_OUT%" >nul 2>&1
exit /b

:GET_FFMPEG
echo.
echo [..] Bajando ffmpeg. Es el pesado, banca un toque...
set "TZ_URL=https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
set "TZ_OUT=%TEMP%\teskadl_ffmpeg.zip"
call :DL
if errorlevel 1 ( del "%TZ_OUT%" >nul 2>&1 & exit /b )
echo [..] Descomprimiendo ffmpeg...
set "TZ_ZIP=%TZ_OUT%"
set "TZ_DEST=%BIN%"
set "TZ_PAT=^(ffmpeg|ffprobe)\.exe$"
call :EXTRACT
del "%TZ_OUT%" >nul 2>&1
exit /b

:GET_DENO
echo.
echo [..] Bajando Deno...
set "TZ_URL=https://github.com/denoland/deno/releases/latest/download/deno-x86_64-pc-windows-msvc.zip"
set "TZ_OUT=%TEMP%\teskadl_deno.zip"
call :DL
if errorlevel 1 ( del "%TZ_OUT%" >nul 2>&1 & exit /b )
echo [..] Descomprimiendo Deno...
set "TZ_ZIP=%TZ_OUT%"
set "TZ_DEST=%BIN%"
set "TZ_PAT=^deno\.exe$"
call :EXTRACT
del "%TZ_OUT%" >nul 2>&1
exit /b

:: --- Descarga TZ_URL a TZ_OUT: curl si existe, si no PowerShell ---
:DL
if not exist "%CURL%" goto DL_PS
"%CURL%" -L --fail --progress-bar -o "%TZ_OUT%" "%TZ_URL%"
exit /b
:DL_PS
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; try { Invoke-WebRequest -UseBasicParsing -Uri $env:TZ_URL -OutFile $env:TZ_OUT } catch { Write-Host $_.Exception.Message; exit 1 }"
exit /b

:: --- Saca de TZ_ZIP los archivos cuyo nombre matchee TZ_PAT hacia TZ_DEST ---
:EXTRACT
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { Add-Type -AssemblyName System.IO.Compression.FileSystem; $z=[IO.Compression.ZipFile]::OpenRead($env:TZ_ZIP); foreach($e in $z.Entries){ if($e.Name -match $env:TZ_PAT){ [IO.Compression.ZipFileExtensions]::ExtractToFile($e,(Join-Path $env:TZ_DEST $e.Name),$true) } }; $z.Dispose() } catch { Write-Host $_.Exception.Message; exit 1 }"
exit /b
