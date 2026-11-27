@echo off

REM Capture the raw script path before enabling expansion inside IF blocks.
setlocal DisableDelayedExpansion
set "PROJECT_ROOT=%~dp0"
setlocal EnableDelayedExpansion

REM Select compatibility explicitly; never modify or restart a saved campaign.
set "BUILD_MAP_OPTION="
:parse_arguments
if "%~1"=="" goto arguments_ready
if /I "%~1"=="--legacy-map01" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap01"
) else if /I "%~1"=="--legacy-tarot-maps" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyTarotMaps"
) else if /I "%~1"=="--legacy-tarot-examples" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyTarotExamples"
) else if /I "%~1"=="--legacy-hunt" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyHunt"
) else if /I "%~1"=="--legacy-map02" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap02"
) else if /I "%~1"=="--legacy-map02-revision4" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap02Revision4"
) else if /I "%~1"=="--legacy-map02-revision5" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap02Revision5"
) else if /I "%~1"=="--legacy-map03-revision3" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap03Revision3"
) else if /I "%~1"=="--legacy-map06" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap06"
) else if /I "%~1"=="--legacy-map06-siege" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap06Siege"
) else if /I "%~1"=="--legacy-map06-north-city" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap06NorthCity"
) else if /I "%~1"=="--legacy-map06-south-city" (
    set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -LegacyMap06SouthCity"
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
set "PROJECT_PK3=!PROJECT_ROOT!build\caelum_argenteum_dev.pk3"

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

REM Start the native game through the standalone-menu bridge, retaining this
REM writable campaign configuration. The bridge applies first-run controls.
python "!PROJECT_ROOT!caelum_standalone.py" --engine "!GZDOOM_EXE!" --iwad "!DOOM2_IWAD!" --package "!PROJECT_PK3!" --config "!PROJECT_ROOT!build\gzdoom.ini"

endlocal
exit /b

:invalid_arguments
echo Usage: run_dev.bat [saved-map compatibility options]
echo --legacy-map01 continues saves that already visited the pre-5.8.2 mansion, without the new connected deposits.
echo --legacy-tarot-maps preserves pre-Justice visited maps.
echo --legacy-tarot-examples preserves the pre-example mansion.
echo --legacy-hunt preserves the previous hunt layout.
echo --legacy-map02-revision4 preserves the pre-5.4.33 sewer.
echo --legacy-map02 continues saves that already visited the original 4.36.4 maze.
echo --legacy-map02-revision5 continues pre-redesign sewer saves, including MAP02 stored in a hub.
echo --legacy-map03-revision3 continues pre-redesign Barracas saves, including MAP03 stored in a hub.
echo MAP06 options below require the complete pre-5.4.29 checkout b9fd71ce.
echo --legacy-map06 continues saves that already visited the pre-siege 4.36.26 port.
echo --legacy-map06-siege continues saves that already visited the 4.36.27-4.37.8 siege port.
echo --legacy-map06-north-city continues saves from the first 4.37.9 city with the northern siege.
echo --legacy-map06-south-city preserves the older southern siege city.
echo --legacy-map06-furnished continues saves that visited the furnished port before 5.4.28.
endlocal
exit /b 2
