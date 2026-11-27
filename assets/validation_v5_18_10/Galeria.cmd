@echo off
chcp 65001 >nul
title Caelum Argenteum - Galeria de modelos 3D
:visita
python -X utf8 "%~dp0launch_gallery.py" %*
if errorlevel 1 echo Consulta el registro de GZDoom indicado arriba.
echo.
echo Pulsa una tecla para volver a abrir la galeria. Cierra esta terminal para salir.
pause >nul
goto visita

