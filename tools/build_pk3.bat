@echo off
setlocal

rem Ejecutar siempre desde la raiz del proyecto, aunque se abra con doble clic.
cd /d "%~dp0.."

if not exist "%~dp0build_pk3.ps1" (
    echo ERROR: No se encontro tools\build_pk3.ps1
    echo Aplica el parche completo y vuelve a intentarlo.
    pause
    exit /b 1
)

echo Construyendo build\caelum_argenteum_dev.pk3...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_pk3.ps1"
set "CAELUM_BUILD_EXIT=%ERRORLEVEL%"

if not "%CAELUM_BUILD_EXIT%"=="0" (
    echo.
    echo La construccion fallo. Revisa el mensaje anterior.
    pause
    exit /b %CAELUM_BUILD_EXIT%
)

echo.
echo Construccion terminada correctamente.
pause
exit /b 0
