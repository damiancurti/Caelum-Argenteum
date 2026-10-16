param(
    [string]$Label = 'audit-01',
    [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$Directory = 'issue304-01',
    [string]$Runtime = 'production.pk3',
    [string]$Fixture = 'corpses.pk3',
    [string]$Script = 'corpses.cfg',
    [string]$LoadGame = '',
    [string]$Map = 'MAP06',
    [int]$Width = 1280,
    [int]$Height = 720,
    [int]$HudScale = 0,
    [string]$Language = 'enu',
    [int]$Seed = 243,
    [switch]$Uncapped,
    [switch]$Interactive,
    [string]$Engine = 'C:\Program Files (x86)\GZDoom\gzdoom.exe',
    [string]$Iwad = 'C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD'
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path (Join-Path $root 'build') $Directory
$config = Join-Path $work "$Label.ini"
if (Test-Path -LiteralPath $config) { throw 'Use a fresh label to preserve evidence.' }
if (Get-CimInstance Win32_Process -Filter "Name='gzdoom.exe'") {
    throw 'A GZDoom engine is already active; preserve it and use one engine at a time.'
}
$initial = "[LastRun]`nVersion=225`n[GlobalSettings]`nvid_preferbackend=1`nvid_vsync=true`nvid_maxfps=60`nvid_activeinbackground=true`ni_pauseinbackground=false`nvid_lowerinbackground=false`ni_soundinbackground=true`nvid_fullscreen=false`nvid_defwidth=$Width`nvid_defheight=$Height`nwin_w=$($Width+16)`nwin_h=$($Height+39)`nwin_maximized=false`nuse_mouse=false`nsnd_mastervolume=0.05`nlanguage=$Language`nhud_scale=$HudScale`n"
if ($Uncapped) { $initial = $initial.Replace('vid_vsync=true','vid_vsync=false').Replace('vid_maxfps=60','vid_maxfps=0') }
[IO.File]::WriteAllText($config, $initial)
if ($Interactive) {
    Copy-Item -LiteralPath (Join-Path $root 'build\gzdoom.ini') -Destination $config -Force
    $initial = [IO.File]::ReadAllText($config)
}
$arguments = @('-noautoload','-nomouse','-iwad',"`"$Iwad`"",'-file',"`"$work\$Runtime`"", "`"$work\$Fixture`"",'-config',"`"$config`"",'-savedir',"`"$work`"",'-width',"$Width",'-height',"$Height",'-window','-rngseed',"$Seed",'-skill','2','+logfile',"`"$work\$Label.txt`"")
if ($LoadGame) { $arguments += @('-loadgame',"`"$LoadGame`"") }
else { $arguments += @('+map',$Map) }
$arguments += @('+exec',"`"$work\$Script`"",'+snd_mastervolume','0.05','+i_pauseinbackground','false','+vid_activeinbackground','true','+i_soundinbackground','true')
if ($Interactive) { $arguments = @($arguments | Where-Object { $_ -ne '-nomouse' }) }
$record = [ordered]@{label=$Label; started_utc=[DateTime]::UtcNow.ToString('o'); arguments=$arguments; initial_config=$initial; engine_sha256=(Get-FileHash -LiteralPath $Engine).Hash; runtime_sha256=(Get-FileHash -LiteralPath (Join-Path $work $Runtime)).Hash; fixture_sha256=(Get-FileHash -LiteralPath (Join-Path $work $Fixture)).Hash}
$record.cpu = @(Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors)
$record.gpu = @(Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion)
$benchPath = Join-Path $work 'benchmarks.txt'
$benchLength = if (Test-Path -LiteralPath $benchPath) { (Get-Item -LiteralPath $benchPath).Length } else { 0 }
$style = if ($Interactive) { 'Normal' } else { 'Hidden' }
$process = Start-Process -FilePath $Engine -ArgumentList $arguments -WorkingDirectory $work -WindowStyle $style -PassThru
$record.pid = $process.Id
$null = $process.Handle
while (!$process.WaitForExit(1000)) {
    $process.Refresh()
    if ($process.MainWindowTitle -match 'Very Fatal Error') {
        $record.native_crash = $true
        Stop-Process -Id $process.Id
        break
    }
    $log = Join-Path $work "$Label.txt"
    if ((Test-Path -LiteralPath $log) -and (Select-String -LiteralPath $log -Pattern 'Script error|errors? while parsing|Unable to resolve|Attempt to redefine|VM execution aborted|DIED WITH FATAL ERROR|This savegame needs' -Quiet)) {
        Stop-Process -Id $process.Id
        $record.engine_error = $log
        break
    }
}
$process.WaitForExit()
$record.exit_code = $process.ExitCode
$record.finished_utc = [DateTime]::UtcNow.ToString('o')
if (Test-Path -LiteralPath $benchPath) {
    $benchBytes = [IO.File]::ReadAllBytes($benchPath)
    if ($benchBytes.Length -gt $benchLength) {
        [IO.File]::WriteAllBytes((Join-Path $work "$Label-bench.txt"),$benchBytes[$benchLength..($benchBytes.Length-1)])
    }
}
$capture = Join-Path $work 'scene.png'
if ((Test-Path -LiteralPath $capture) -and (Get-Item -LiteralPath $capture).LastWriteTimeUtc -ge [DateTime]::Parse($record.started_utc)) {
    Copy-Item -LiteralPath $capture -Destination (Join-Path $work "$Label-scene.png")
}
$record | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath "$work\$Label-run.json" -Encoding utf8
if ($process.ExitCode -ne 0) { throw "Engine exit code $($process.ExitCode)" }
if ($record.engine_error -or $record.native_crash) { throw 'Native engine failure; inspect preserved evidence.' }
if (Select-String -LiteralPath "$work\$Label.txt" -Pattern 'CA304 FAIL|Script error|VM execution aborted' -Quiet) { throw 'Audit failed; inspect the full preserved log.' }
if ($Interactive) { Write-Host 'Manual session closed normally. Author confirmation remains separate.'; return }
if (!(Select-String -LiteralPath "$work\$Label.txt" -SimpleMatch 'CA304 DONE failures=0' -Quiet)) { throw 'Missing completion marker.' }
Select-String -LiteralPath "$work\$Label.txt" -SimpleMatch 'CA304 DONE'
