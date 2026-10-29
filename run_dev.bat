@echo off

REM Delayed expansion preserves paths containing parentheses inside IF.
setlocal EnableDelayedExpansion

REM Select compatibility explicitly; never modify or restart a saved campaign.
set "BUILD_MAP_OPTION="
if not "%~4"=="" goto invalid_arguments
:parse_arguments
if "%~1"=="" goto arguments_ready
if /I "%~1"=="--legacy-map01" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap01"
) else if /I "%~1"=="--legacy-map02" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap02"
) else if /I "%~1"=="--legacy-map06" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap06"
) else if /I "%~1"=="--legacy-map06-siege" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap06Siege"
) else if /I "%~1"=="--legacy-map06-north-city" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap06NorthCity"
) else if /I "%~1"=="--legacy-map06-furnished" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap06Furnished"
) else goto invalid_arguments
shift
goto parse_arguments
:arguments_ready

REM Engine path in the installation supplied by the author.
set "GZDOOM_EXE=C:\Program Files (x86)\GZDoom\gzdoom.exe"

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
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "!PROJECT_ROOT!build_dev.ps1" !BUILD_MAP_OPTION!
set "BUILD_EXIT=!ERRORLEVEL!"
popd

REM Stop startup if the build fails.
if not "!BUILD_EXIT!"=="0" (
    echo.
    echo ERROR: The development PK3 could not be built.
    pause
    exit /b 1
)

REM Start GZDoom with the newly rebuilt PK3. The -config below avoids the GZDoom 4.14.2 startup crash on this Windows build and keeps the INI writable.
REM Apply the accepted preset only when this launcher's INI does not exist.
set "FIRST_CONTROL_PRESET="
if not exist "!PROJECT_ROOT!build\gzdoom.ini" set "FIRST_CONTROL_PRESET=+exec "!PROJECT_ROOT!assets\playtest\default_controls.cfg""
"!GZDOOM_EXE!" -iwad "!DOOM2_IWAD!" -file "!PROJECT_PK3!" -config "!PROJECT_ROOT!build\gzdoom.ini" !FIRST_CONTROL_PRESET!

endlocal
exit /b

:invalid_arguments
echo Usage: run_dev.bat [--legacy-map01] [--legacy-map02] [--legacy-map06 ^| --legacy-map06-siege ^| --legacy-map06-north-city ^| --legacy-map06-furnished]
echo --legacy-map01 continues saves that already visited the pre-5.8.2 mansion, without the new connected deposits.
echo --legacy-map02 continues saves that already visited the original 4.36.4 maze.
echo MAP06 options below require the complete pre-5.4.29 checkout b9fd71ce.
echo --legacy-map06 continues saves that already visited the pre-siege 4.36.26 port.
echo --legacy-map06-siege continues saves that already visited the 4.36.27-4.37.8 siege port.
echo --legacy-map06-north-city continues saves from the first 4.37.9 city with the northern siege.
echo --legacy-map06-furnished continues saves that visited the furnished port before 5.4.28.
endlocal
exit /b 2
