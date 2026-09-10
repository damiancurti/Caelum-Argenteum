@echo off

REM La expansion retardada conserva rutas con parentesis dentro de IF.
setlocal EnableDelayedExpansion

REM Ruta del motor en la instalacion suministrada por el autor.
set "GZDOOM_EXE=C:\Users\dcc70\OneDrive\Documentos\GZDooM\gzdoom.exe"

REM IWAD de desarrollo instalado por el autor.
set "DOOM2_IWAD=C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD"

REM La raiz del proyecto es la carpeta de este archivo.
set "PROJECT_ROOT=%~dp0"
set "PROJECT_PK3=%PROJECT_ROOT%build\caelum_argenteum_dev.pk3"

REM Comprobar que exista el motor.
if not exist "!GZDOOM_EXE!" (
    echo ERROR: gzdoom.exe was not found at:
    echo !GZDOOM_EXE!
    echo.
    pause
    exit /b 1
)

REM Comprobar que exista el IWAD de desarrollo.
if not exist "!DOOM2_IWAD!" (
    echo ERROR: DOOM2.WAD was not found at:
    echo !DOOM2_IWAD!
    echo.
    pause
    exit /b 1
)

REM Compilar con el constructor unico de la raiz.
pushd "!PROJECT_ROOT!"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "!PROJECT_ROOT!build_dev.ps1"
set "BUILD_EXIT=!ERRORLEVEL!"
popd

REM Detener el inicio si falla la compilacion.
if not "!BUILD_EXIT!"=="0" (
    echo.
    echo ERROR: The development PK3 could not be built.
    pause
    exit /b 1
)

REM Iniciar GZDoom con el PK3 recien reconstruido.
"!GZDOOM_EXE!" -iwad "!DOOM2_IWAD!" -file "!PROJECT_PK3!"

endlocal
