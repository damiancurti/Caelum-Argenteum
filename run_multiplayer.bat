@echo off
setlocal
cd /d "%~dp0"
REM Build and validate the current package before opening the session menu.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_dev.ps1"
if errorlevel 1 (
    pause
    exit /b 1
)
python "%~dp0caelum_session_menu.py" --engine "C:\Program Files (x86)\GZDoom\gzdoom.exe" --iwad "C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD" --package "%~dp0build\caelum_argenteum_dev.pk3" %*
if errorlevel 1 pause
endlocal
