param(
    [string]$Engine = 'C:\Program Files (x86)\GZDoom\gzdoom.exe',
    [string]$Label = 'checks-a',
    [string]$Package = 'production.pk3',
    [string]$Addon = 'checks.pk3',
    [string]$Map = 'MAP06',
    [string]$Script = 'checks.cfg',
    [string]$LoadGame = '',
    [string]$Language = 'enu',
    [int]$Staged = 1,
    [int]$Width = 1280,
    [int]$Height = 720,
    [int]$MinimumTic = 0,
    [switch]$Capture,
    [string]$Expected = 'CA132 COMPLETE checks=\d+ failures=0'
)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build/issue132'
& (Join-Path $PSScriptRoot 'run_native.ps1') -Engine $Engine -Label $Label -Package $Package -Addon $Addon -Map $Map -Script $Script -LoadGame $LoadGame -Language $Language -Staged $Staged -Width $Width -Height $Height -Capture:$Capture
$record = Get-Content -LiteralPath (Join-Path $work "$Label-run.json") -Raw | ConvertFrom-Json
$owned = Get-Process -Id $record.pid -ErrorAction SilentlyContinue
if ($owned -and ($owned.ProcessName -ne 'gzdoom' -or [Math]::Abs(($owned.StartTime.ToUniversalTime()-[DateTime]::Parse($record.started_utc).ToUniversalTime()).TotalSeconds) -gt 60)) { throw 'Recorded PID is not the owned engine.' }
$timer = [Diagnostics.Stopwatch]::StartNew()
$raw = ''
while ($owned -and !$owned.HasExited) {
    $null = $owned.WaitForExit(1000)
    $path = Join-Path $work "$Label.txt"
    if (Test-Path -LiteralPath $path) { $raw = Get-Content -LiteralPath $path -Raw -Encoding utf8 }
    if ($raw -match 'This savegame needs these files:|Not in a saveable game.|Script error,|VM execution aborted|Unable to resolve all fields|DIED WITH FATAL ERROR|CA132 FAIL' -or $timer.Elapsed.TotalMinutes -gt 180) {
        Stop-Process -Id $record.pid -ErrorAction SilentlyContinue
        Write-Output ($raw -split "`n" | Where-Object { $_ -notmatch '^Vulkan extensions:' } | Select-Object -Last 15)
        throw "Native check failed: $Label. Original evidence retained in build/issue132."
    }
}
$raw = [IO.File]::ReadAllText((Join-Path $work "$Label.txt"))
if ($raw -match 'This savegame needs these files:|Not in a saveable game.|Script error,|VM execution aborted|Unable to resolve all fields|DIED WITH FATAL ERROR|CA132 FAIL') { throw "Native error in completed log: $Label" }
if ($raw -notmatch $Expected) { throw "Missing expected completion in $Label" }
if ($MinimumTic -gt 0) {
    $ticks = @([regex]::Matches($raw, 'CA(?:121|132) SIM tic=(\d+)') | ForEach-Object { [int]$_.Groups[1].Value })
    if (!$ticks.Count -or $ticks[-1] -lt $MinimumTic) { throw "Native run did not reach tic $MinimumTic : $Label" }
    $record | Add-Member -NotePropertyName last_observed_tic -NotePropertyValue $ticks[-1] -Force
}
$exitDeadline = [DateTime]::UtcNow.AddSeconds(5)
while (Get-Process -Id $record.pid -ErrorAction SilentlyContinue) {
    if ([DateTime]::UtcNow -gt $exitDeadline) { throw "Owned engine PID has not left the process list: $Label" }
    Start-Sleep -Milliseconds 100
}
$record | Add-Member -NotePropertyName completed_utc -NotePropertyValue ([DateTime]::UtcNow.ToString('o')) -Force
$record | Add-Member -NotePropertyName expected -NotePropertyValue $Expected -Force
if ($Capture) {
    $captureDeadline = [DateTime]::UtcNow.AddSeconds(40)
    while (!(Test-Path -LiteralPath (Join-Path $work ($Label+'.capture-done.json')))) {
        if ([DateTime]::UtcNow -gt $captureDeadline) { throw "Capture did not finish: $Label. Native engine evidence remains intact." }
        Start-Sleep -Milliseconds 500
    }
    if (!(Test-Path -LiteralPath (Join-Path $work ($Label+'-present.csv')))) { throw "Missing presentation trace: $Label" }
    $record | Add-Member -NotePropertyName presentation_sha256 -NotePropertyValue ((Get-FileHash -LiteralPath (Join-Path $work ($Label+'-present.csv'))).Hash) -Force
}
$record | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $work "$Label-run.json") -Encoding utf8
foreach ($suffix in @('.txt','.ini','-run.json')) {
    Copy-Item -LiteralPath (Join-Path $work ($Label+$suffix)) -Destination (Join-Path $PSScriptRoot ($Label+$suffix))
}
Write-Output "COMPLETED $Label"
