@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -File "%~dp0Apply-configuration.ps1"
echo.
pause
