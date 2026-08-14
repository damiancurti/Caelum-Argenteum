@echo off

REM Delayed expansion prevents parentheses in paths such as "Program Files
REM (x86)" from being interpreted as batch-file syntax inside IF blocks.
setlocal EnableDelayedExpansion

REM This is the full path to the GZDoom executable on Damian's computer.
set "GZDOOM_EXE=C:\Users\dcc70\OneDrive\Documentos\GZDooM\gzdoom.exe"

REM This is the legally installed Doom II IWAD used during development.
set "DOOM2_IWAD=C:\Program Files (x86)\Steam\steamapps\common\DOOM 3 BFG Edition\base\wads\DOOM2.WAD"

REM %~dp0 means the folder in which this batch file is located.
set "PROJECT_ROOT=%~dp0"
set "PROJECT_PK3=%PROJECT_ROOT%build\caelum_argenteum_dev.pk3"

REM Stop here and explain the problem if GZDoom cannot be found.
if not exist "!GZDOOM_EXE!" (
    echo ERROR: gzdoom.exe was not found at:
    echo !GZDOOM_EXE!
    echo.
    pause
    exit /b 1
)

REM Stop here and explain the problem if DOOM2.WAD cannot be found.
if not exist "!DOOM2_IWAD!" (
    echo ERROR: DOOM2.WAD was not found at:
    echo !DOOM2_IWAD!
    echo.
    pause
    exit /b 1
)

REM Build a fresh PK3 from the files inside the src folder.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "!PROJECT_ROOT!build_dev.ps1"

REM Do not start GZDoom if the build script reported an error.
if errorlevel 1 (
    echo.
    echo ERROR: The development PK3 could not be built.
    pause
    exit /b 1
)

REM Launch GZDoom, select Doom II, and load the newly generated PK3.
"!GZDOOM_EXE!" -iwad "!DOOM2_IWAD!" -file "!PROJECT_PK3!"

endlocal
