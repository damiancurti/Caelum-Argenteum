@echo off

REM Delayed expansion preserves paths containing parentheses inside IF.
setlocal EnableDelayedExpansion

REM Engine path in the installation supplied by the author.
set "GZDOOM_EXE=C:\Users\dcc70\OneDrive\Documentos\GZDooM\gzdoom.exe"

REM Development IWAD installed by the author.
set "DOOM2_IWAD=C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD"

REM The project root is the directory containing this file.
set "PROJECT_ROOT=%~dp0"
set "PROJECT_PK3=%PROJECT_ROOT%build\caelum_argenteum_dev.pk3"

REM Check that the engine exists.
if not exist "!GZDOOM_EXE!" (
    echo ERROR: gzdoom.exe was not found at:
    echo !GZDOOM_EXE!
    echo.
    pause
    exit /b 1
)

REM Check that the development IWAD exists.
if not exist "!DOOM2_IWAD!" (
    echo ERROR: DOOM2.WAD was not found at:
    echo !DOOM2_IWAD!
    echo.
    pause
    exit /b 1
)

REM Build with the authoritative builder in the project root.
pushd "!PROJECT_ROOT!"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "!PROJECT_ROOT!build_dev.ps1"
set "BUILD_EXIT=!ERRORLEVEL!"
popd

REM Stop startup if the build fails.
if not "!BUILD_EXIT!"=="0" (
    echo.
    echo ERROR: The development PK3 could not be built.
    pause
    exit /b 1
)

REM Start GZDoom with the newly rebuilt PK3.
"!GZDOOM_EXE!" -iwad "!DOOM2_IWAD!" -file "!PROJECT_PK3!"

endlocal
