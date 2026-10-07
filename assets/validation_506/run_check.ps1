param(
    [string]$Label = 'checks-a',
    [string]$Package = 'current.pk3',
    [string]$Addon = 'checks.pk3',
    [string]$Map = 'QA128A',
    [string]$Script = 'checks.cfg',
    [string]$LoadGame = '',
    [string]$Expected = 'CA128 COMPLETE checks=\d+ failures=0'
)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build/issue128'
& (Join-Path $PSScriptRoot 'run_native.ps1') -Label $Label -Package $Package -Addon $Addon -Map $Map -Script $Script -LoadGame $LoadGame
$record = Get-Content -LiteralPath (Join-Path $work "$Label-run.json") -Raw | ConvertFrom-Json
$owned = Get-Process -Id $record.pid -ErrorAction SilentlyContinue
if ($owned -and ($owned.ProcessName -ne 'gzdoom' -or [Math]::Abs(($owned.StartTime.ToUniversalTime()-[DateTime]::Parse($record.started_utc).ToUniversalTime()).TotalSeconds) -gt 60)) { throw 'Recorded PID is not the owned engine.' }
$timer = [Diagnostics.Stopwatch]::StartNew()
$raw = ''
while ($owned -and !$owned.HasExited) {
    $null = $owned.WaitForExit(1000)
    $path = Join-Path $work "$Label.txt"
    if (Test-Path -LiteralPath $path) { $raw = Get-Content -LiteralPath $path -Raw -Encoding utf8 }
    if ($raw -match 'Script error,|VM execution aborted|Unable to resolve all fields|CA128 FAIL' -or $timer.Elapsed.TotalMinutes -gt 10) {
        Stop-Process -Id $record.pid -ErrorAction SilentlyContinue
        Write-Output ($raw -split "`n" | Select-Object -Last 45)
        throw "Native check failed: $Label. Original evidence retained in build/issue128."
    }
}
$raw = [IO.File]::ReadAllText((Join-Path $work "$Label.txt"))
if ($raw -notmatch $Expected) { throw "Missing expected completion in $Label" }
$record | Add-Member -NotePropertyName completed_utc -NotePropertyValue ([DateTime]::UtcNow.ToString('o')) -Force
$record | Add-Member -NotePropertyName expected -NotePropertyValue $Expected -Force
$record | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $work "$Label-run.json") -Encoding utf8
foreach ($suffix in @('.txt','.ini','-run.json')) {
    Copy-Item -LiteralPath (Join-Path $work ($Label+$suffix)) -Destination (Join-Path $PSScriptRoot ($Label+$suffix))
}
Write-Output "COMPLETED $Label"
