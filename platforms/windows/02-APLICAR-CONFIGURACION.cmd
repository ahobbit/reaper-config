@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -File "%~dp0Aplicar-configuracion.ps1"
echo.
pause
