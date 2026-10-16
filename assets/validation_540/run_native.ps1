param(
    [string]$Label = 'audit-01',
    [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$Directory = 'issue237',
    [string]$Engine = 'C:\Program Files (x86)\GZDoom\gzdoom.exe',
    [string]$Iwad = 'C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD'
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path (Join-Path $root 'build') $Directory
$config = Join-Path $work "$Label.ini"
if (Test-Path -LiteralPath $config) { throw 'Use a fresh label to preserve evidence.' }
if (Get-CimInstance Win32_Process -Filter "Name='gzdoom.exe'" | Where-Object { $_.CommandLine -like "*$work\*" }) {
    throw 'An issue237 engine run is already active.'
}
$initial = "[LastRun]`nVersion=225`n[GlobalSettings]`nvid_preferbackend=1`nvid_vsync=true`nvid_maxfps=60`nvid_activeinbackground=true`ni_pauseinbackground=false`nvid_lowerinbackground=false`ni_soundinbackground=true`nvid_fullscreen=false`nuse_mouse=false`nsnd_mastervolume=0.05`nlanguage=enu`n"
[IO.File]::WriteAllText($config, $initial)
$arguments = @('-noautoload','-nomouse','-iwad',"`"$Iwad`"",'-file',"`"$work\production.pk3`"", "`"$work\probe.pk3`"",'-config',"`"$config`"",'-savedir',"`"$work`"",'-width','1280','-height','720','-window','-rngseed','237','-skill','2','+logfile',"`"$work\$Label.txt`"",'+map','MAP02','+exec',"`"$work\probe.cfg`"")
$record = [ordered]@{label=$Label; started_utc=[DateTime]::UtcNow.ToString('o'); arguments=$arguments; initial_config=$initial; engine_sha256=(Get-FileHash -LiteralPath $Engine).Hash}
$process = Start-Process -FilePath $Engine -ArgumentList $arguments -WorkingDirectory $work -WindowStyle Hidden -PassThru
$record.pid = $process.Id
$null = $process.Handle
while (!$process.WaitForExit(1000)) {
    $log = Join-Path $work "$Label.txt"
    if ((Test-Path -LiteralPath $log) -and (Select-String -LiteralPath $log -Pattern 'Script error|errors while parsing|VM execution aborted|DIED WITH FATAL ERROR' -Quiet)) {
        Stop-Process -Id $process.Id
        throw "Engine error: $log"
    }
}
$record.exit_code = $process.ExitCode
$record.finished_utc = [DateTime]::UtcNow.ToString('o')
$record | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath "$work\$Label-run.json" -Encoding utf8
if ($process.ExitCode -ne 0) { throw "Engine exit code $($process.ExitCode)" }
if (Select-String -LiteralPath "$work\$Label.txt" -Pattern 'CA237 FAIL|Script error|VM execution aborted' -Quiet) { throw 'Audit failed; inspect the full preserved log.' }
if (!(Select-String -LiteralPath "$work\$Label.txt" -SimpleMatch 'CA237 DONE failures=0' -Quiet)) { throw 'Missing completion marker.' }
Select-String -LiteralPath "$work\$Label.txt" -SimpleMatch 'CA237 DONE'
