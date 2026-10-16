param(
    [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$Label = 'audit-01',
    [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$Directory = 'issue283',
    [string]$Runtime = 'production.pk3',
    [string]$Fixture = 'pilot.pk3',
    [string]$Script = 'preview.cfg',
    [string]$LoadGame = '',
    [string]$Map = 'MAP99',
    [int]$Width = 1280,
    [int]$Height = 720,
    [int]$HudScale = 0,
    [double]$HudFactor = 1,
    [switch]$ModernHUD,
    [string]$Language = 'enu',
    [switch]$Interactive,
    [string]$Engine = 'C:\Program Files (x86)\GZDoom\gzdoom.exe',
    [string]$Iwad = 'C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD'
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path (Join-Path $root 'build') $Directory
foreach ($required in @('manifest.json', $Runtime, $Fixture, $Script)) {
    if (!(Test-Path -LiteralPath (Join-Path $work $required))) { throw "Fixture is not ready: $required" }
}
$manifest = Get-Content -Raw -LiteralPath (Join-Path $work 'manifest.json') | ConvertFrom-Json
if ($Runtime -eq 'production.pk3' -and (Get-FileHash -LiteralPath (Join-Path $work $Runtime)).Hash -ne $manifest.runtime_sha256) { throw 'Runtime differs from the completed fixture manifest.' }
if ($Fixture -eq 'pilot.pk3' -and (Get-FileHash -LiteralPath (Join-Path $work $Fixture)).Hash -ne $manifest.fixture_sha256) { throw 'Fixture differs from the completed fixture manifest.' }
$config = Join-Path $work "$Label.ini"
if (Test-Path -LiteralPath $config) { throw 'Use a fresh label to preserve evidence.' }
if (Get-CimInstance Win32_Process -Filter "Name='gzdoom.exe'") {
    throw 'A GZDoom engine is already active; preserve it and use one engine at a time.'
}
$runScript = Join-Path $work "$Label-commands.cfg"
$scriptText = [IO.File]::ReadAllText((Join-Path $work $Script)).Replace('screenshot pilot-', "screenshot $Label-pilot-")
[IO.File]::WriteAllText($runScript, $scriptText)
$initial = "[LastRun]`nVersion=225`n[GlobalSettings]`nvid_preferbackend=1`nvid_vsync=true`nvid_maxfps=60`nvid_activeinbackground=true`ni_pauseinbackground=false`nvid_lowerinbackground=false`ni_soundinbackground=true`nvid_fullscreen=false`nvid_defwidth=$Width`nvid_defheight=$Height`nwin_w=$($Width+16)`nwin_h=$($Height+39)`nwin_maximized=false`nuse_mouse=false`nsnd_mastervolume=0.05`nlanguage=$Language`nhud_scale=$HudScale`n"
[IO.File]::WriteAllText($config, $initial)
if ($Interactive) {
    Copy-Item -LiteralPath (Join-Path $root 'build\gzdoom.ini') -Destination $config -Force
    $initial = [IO.File]::ReadAllText($config)
}
$arguments = @('-noautoload','-nomouse','-iwad',"`"$Iwad`"",'-file',"`"$work\$Runtime`"", "`"$work\$Fixture`"",'-config',"`"$config`"",'-savedir',"`"$work`"",'-width',"$Width",'-height',"$Height",'-window','-rngseed','283','-skill','2','+logfile',"`"$work\$Label.txt`"")
if ($LoadGame) { $arguments += @('-loadgame',"`"$LoadGame`"") }
else { $arguments += @('+map',$Map) }
$arguments += @('+exec',"`"$runScript`"",'+snd_mastervolume','0.05','+i_pauseinbackground','false','+vid_activeinbackground','true','+i_soundinbackground','true')
if ($ModernHUD) { $arguments += @('+hud_oldscale','false','+hud_scalefactor',([string]$HudFactor)) }
if ($Interactive) { $arguments = @($arguments | Where-Object { $_ -ne '-nomouse' }) }
$record = [ordered]@{label=$Label; started_utc=[DateTime]::UtcNow.ToString('o'); arguments=$arguments; initial_config=$initial; engine_sha256=(Get-FileHash -LiteralPath $Engine).Hash; runtime_sha256=(Get-FileHash -LiteralPath (Join-Path $work $Runtime)).Hash; fixture_sha256=(Get-FileHash -LiteralPath (Join-Path $work $Fixture)).Hash}
$style = if ($Interactive) { 'Normal' } else { 'Hidden' }
$process = Start-Process -FilePath $Engine -ArgumentList $arguments -WorkingDirectory $work -WindowStyle $style -PassThru
$record.pid = $process.Id
$null = $process.Handle
while (!$process.WaitForExit(1000)) {
    $process.Refresh()
    if ($process.MainWindowTitle -like 'Fatal Error*') {
        throw 'Native fatal-error dialog detected; preserve and inspect it before another run.'
    }
    $log = Join-Path $work "$Label.txt"
    if ((Test-Path -LiteralPath $log) -and (Select-String -LiteralPath $log -Pattern 'Could not open|Default values for parameter|Unknown identifier|JIT error|REGT_ADDROF|Script error|errors? while parsing|Attempt to change scope|Attempt to redefine|VM execution aborted|DIED WITH FATAL ERROR|This savegame needs' -Quiet)) {
        Stop-Process -Id $process.Id
        throw "Engine error: $log"
    }
}
$record.exit_code = $process.ExitCode
$record.finished_utc = [DateTime]::UtcNow.ToString('o')
$record | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath "$work\$Label-run.json" -Encoding utf8
if ($process.ExitCode -ne 0) { throw "Engine exit code $($process.ExitCode)" }
if (Select-String -LiteralPath "$work\$Label.txt" -Pattern 'CA283 FAIL|Script error|VM execution aborted' -Quiet) { throw 'Audit failed; inspect the full preserved log.' }
if (!(Select-String -LiteralPath "$work\$Label.txt" -Pattern 'CA283 DONE passes=[0-9]+ failures=0' -Quiet)) { throw 'Missing completion marker.' }
Select-String -LiteralPath "$work\$Label.txt" -SimpleMatch 'CA283 DONE'
