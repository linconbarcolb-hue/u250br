@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo U250 - BAIXAR CAPAS DOS ALBUNS
echo ==================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0BAIXAR-CAPAS-U2.ps1"

echo.
echo Baixando tambem a imagem local de Carnaval De Luz...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0BAIXAR-IMAGEM-CARNAVAL.ps1"
