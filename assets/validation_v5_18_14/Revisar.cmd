@echo off
chcp 65001 >nul
title Caelum Argenteum - Modelos, caidas y Zupay - Sin sonido
:revisar
python -X utf8 "%~dp0motion_review.py" %*
if errorlevel 1 echo Revisa el registro de GZDoom indicado arriba.
echo.
echo Pulsa una tecla para volver a la galeria, o cierra esta terminal.
pause >nul
goto revisar
