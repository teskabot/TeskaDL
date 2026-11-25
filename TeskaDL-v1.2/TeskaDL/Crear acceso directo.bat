@echo off
title TeskaDL - Crear acceso directo
set "HERE=%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$h='%HERE%'; $q=[char]34; $ws=New-Object -ComObject WScript.Shell; $ico=Join-Path $h 'teskaDL.ico'; foreach($p in @([Environment]::GetFolderPath('Programs'),[Environment]::GetFolderPath('Desktop'))){ $s=$ws.CreateShortcut((Join-Path $p 'TeskaDL.lnk')); $s.TargetPath=(Join-Path $env:WINDIR 'System32\cmd.exe'); $s.Arguments='/c '+$q+(Join-Path $h 'TeskaDL.bat')+$q; $s.WorkingDirectory=$h; if(Test-Path $ico){ $s.IconLocation=$ico }; $s.Save() }"

echo.
echo [OK] Acceso directo creado en el Escritorio y en el menu Inicio.
echo      Para fijarlo: Inicio, busca "TeskaDL", clic derecho, Anclar a la barra de tareas.
echo.
echo  Ojo: si moves la carpeta TeskaDL, volve a correr este archivo.
echo.
pause
