@echo off
chcp 65001 >nul
title Caelum Argenteum - Probador de equipo - Sin sonido
:revisar
python -X utf8 "%~dp0fitting_room.py" %*
if errorlevel 1 echo Comprueba el registro de GZDoom en la carpeta de la prueba.
echo.
echo Pulsa una tecla para volver al probador o cierra esta terminal.
pause >nul
goto revisar
