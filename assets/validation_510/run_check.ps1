param(
    [string]$Label = 'checks-a',
    [string]$Package = 'production.pk3',
    [string]$Addon = 'checks.pk3',
    [string]$Map = 'QA130A',
    [string]$Script = 'checks.cfg',
    [string]$LoadGame = '',
    [string]$Language = 'enu',
    [int]$MinimumTic = 0,
    [string]$Expected = 'CA130 COMPLETE checks=\d+ failures=0'
)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build/issue130'
& (Join-Path $PSScriptRoot 'run_native.ps1') -Label $Label -Package $Package -Addon $Addon -Map $Map -Script $Script -LoadGame $LoadGame -Language $Language
$record = Get-Content -LiteralPath (Join-Path $work "$Label-run.json") -Raw | ConvertFrom-Json
$owned = Get-Process -Id $record.pid -ErrorAction SilentlyContinue
if ($owned -and ($owned.ProcessName -ne 'gzdoom' -or [Math]::Abs(($owned.StartTime.ToUniversalTime()-[DateTime]::Parse($record.started_utc).ToUniversalTime()).TotalSeconds) -gt 60)) { throw 'Recorded PID is not the owned engine.' }
$timer = [Diagnostics.Stopwatch]::StartNew()
$raw = ''
while ($owned -and !$owned.HasExited) {
    $null = $owned.WaitForExit(1000)
    $path = Join-Path $work "$Label.txt"
    if (Test-Path -LiteralPath $path) { $raw = Get-Content -LiteralPath $path -Raw -Encoding utf8 }
    if ($raw -match 'Script error,|VM execution aborted|Unable to resolve all fields|DIED WITH FATAL ERROR|CA130 FAIL' -or $timer.Elapsed.TotalMinutes -gt 10) {
        Stop-Process -Id $record.pid -ErrorAction SilentlyContinue
        Write-Output ($raw -split "`n" | Where-Object { $_ -notmatch '^Vulkan extensions:' } | Select-Object -Last 15)
        throw "Native check failed: $Label. Original evidence retained in build/issue130."
    }
}
$raw = [IO.File]::ReadAllText((Join-Path $work "$Label.txt"))
if ($raw -match 'Script error,|VM execution aborted|Unable to resolve all fields|DIED WITH FATAL ERROR|CA130 FAIL') { throw "Native error in completed log: $Label" }
if ($raw -notmatch $Expected) { throw "Missing expected completion in $Label" }
if ($MinimumTic -gt 0) {
    $ticks = @([regex]::Matches($raw, 'CA121 SIM tic=(\d+)') | ForEach-Object { [int]$_.Groups[1].Value })
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
$record | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $work "$Label-run.json") -Encoding utf8
foreach ($suffix in @('.txt','.ini','-run.json')) {
    Copy-Item -LiteralPath (Join-Path $work ($Label+$suffix)) -Destination (Join-Path $PSScriptRoot ($Label+$suffix))
}
Write-Output "COMPLETED $Label"
