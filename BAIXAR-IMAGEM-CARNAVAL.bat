@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo U250 - BAIXAR IMAGEM CARNAVAL DE LUZ
echo =========================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0BAIXAR-IMAGEM-CARNAVAL.ps1"
