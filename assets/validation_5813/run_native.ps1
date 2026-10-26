param(
    [Parameter(Mandatory=$true)][string]$Label,
    [string]$Runtime = 'current',
    [string]$Script = 'core',
    [string]$Language = 'enu',
    [string]$LoadGame = '',
    [string]$Addon = '',
    [string]$StartMap = 'MAP01',
    [int]$TimeoutSeconds = 60,
    [switch]$Checks,
    [switch]$Interactive
)
$ErrorActionPreference = 'Stop'
if (Get-Process gzdoom -ErrorAction SilentlyContinue) {
    throw 'An existing GZDoom session is running; native tests must not overlap.'
}
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build\issue411-fire'
if ($LoadGame -and [IO.Path]::IsPathRooted($LoadGame)) {
    throw 'LoadGame must be a filename relative to build/issue411-fire; GZDoom prepends savedir.'
}
$engine = 'C:\Program Files (x86)\GZDoom\gzdoom.exe'
$iwad = 'C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD'
$package = Join-Path $work "$Runtime\caelum_argenteum_dev.pk3"
$config = Join-Path $work "$Label.ini"
if (Test-Path -LiteralPath $config) { throw 'Use a new label to preserve prior evidence.' }
$initial = @"
[LastRun]
Version=225
[GlobalSettings]
vid_preferbackend=1
vid_vsync=false
vid_maxfps=60
vid_activeinbackground=true
i_pauseinbackground=false
vid_lowerinbackground=false
i_soundinbackground=true
cl_capfps=false
vid_fullscreen=false
vid_defwidth=1280
vid_defheight=720
win_w=1296
win_h=759
win_maximized=false
use_mouse=false
snd_mastervolume=0.05
language=$Language
"@
if ($Interactive) { $initial = $initial.Replace('use_mouse=false', 'use_mouse=true') }
[IO.File]::WriteAllText($config, $initial, [Text.UTF8Encoding]::new($false))
$arguments = @('-noautoload', '-iwad', "`"$iwad`"", '-file', "`"$package`"")
if (!$Addon) { $Addon = if ($Runtime -eq 'baseline') { 'legacy-checks.pk3' } else { 'checks.pk3' } }
if ($Checks) { $arguments += "`"$work\$addon`"" }
$arguments += @('-config', "`"$config`"", '-savedir', "`"$work`"",
    '-width', '1280', '-height', '720', '-window', '-rngseed', '411',
    '-skill', '2', '+logfile', "`"$work\$Label.txt`"", '+con_notifytime', '0')
if (!$Interactive) { $arguments += '-nomouse' }
if ($LoadGame) { $arguments += @('-loadgame', "`"$LoadGame`"") }
else { $arguments += @('+map', $StartMap) }
$scriptPath = Join-Path $work "$Script.cfg"
if ($Script -eq 'smoke') { [IO.File]::WriteAllText($scriptPath, "wait 70; quit`n") }
$arguments += @('+exec', "`"$scriptPath`"")
$record = [ordered]@{
    label=$Label; runtime=$Runtime; started_utc=[DateTime]::UtcNow.ToString('o');
    engine=$engine; engine_sha256=(Get-FileHash -LiteralPath $engine).Hash;
    iwad_sha256=(Get-FileHash -LiteralPath $iwad).Hash;
    package_sha256=(Get-FileHash -LiteralPath $package).Hash;
    addon_sha256=$(if($Checks){(Get-FileHash -LiteralPath "$work\$addon").Hash}else{''});
    initial_config=$initial; arguments=$arguments;
    command_script=[IO.File]::ReadAllText($scriptPath);
    cpu=@(Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors);
    gpu=@(Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion);
    os=Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version
}
$style = if ($Interactive) { 'Normal' } else { 'Hidden' }
$process = Start-Process -FilePath $engine -ArgumentList $arguments -WorkingDirectory $work -WindowStyle $style -PassThru
$record.pid = $process.Id
$record | ConvertTo-Json -Depth 6 | Set-Content -Encoding utf8 -LiteralPath "$work\$Label-run.json"
Write-Output "Started $Label, PID $($process.Id)"
if ($Interactive) { return }
$null = $process.Handle
$deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
while (!$process.WaitForExit(250) -and [DateTime]::UtcNow -lt $deadline) {
    $taskNativeLog=Join-Path $work "$Label.txt"
    if((Test-Path -LiteralPath $taskNativeLog) -and
        (Select-String -LiteralPath $taskNativeLog -Quiet -Pattern 'Script error|VM execution aborted|Fatal:')) {
        $record.startup_error=$true
        $process.Kill()
        $process.WaitForExit()
        break
    }
}
if (!$process.HasExited) {
    $process.Kill()
    $record.timed_out = $true
    $process.WaitForExit()
}
$record.exit_code = $process.ExitCode
$record.finished_utc = [DateTime]::UtcNow.ToString('o')
$record | ConvertTo-Json -Depth 6 | Set-Content -Encoding utf8 -LiteralPath "$work\$Label-run.json"
if ($record.exit_code -ne 0 -or $record.timed_out) { throw "Native run failed: $Label" }
$log = Get-Content -LiteralPath "$work\$Label.txt"
$log | Select-String 'CA411F (FAIL|RESULT|PERSIST|LEGACY|CARDINAL)|Script error|Error|Warning|VM execution aborted'
if ($log | Select-String 'CA411F FAIL|Script error|VM execution aborted|failures=[1-9]|failed=[1-9]|DIED WITH FATAL ERROR|This savegame needs|Cannot find savegame|Not in a saveable game') { throw "Native assertions, VM or save loading failed: $Label" }
if ($Checks -and !($log | Select-String 'CA411F (RESULT|LEGACY)')) { throw "Expected native checks did not execute: $Label" }
