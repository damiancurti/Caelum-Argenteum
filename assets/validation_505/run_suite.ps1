param(
    [string]$AttachLabel = '',
    [string]$StartAt = '',
    [string]$Engine = 'C:\Program Files (x86)\GZDoom\gzdoom.exe',
    [string]$Iwad = 'C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD'
)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build\issue121'
function Complete-Run([string]$label, [int]$minimumTic) {
    $metadataPath = Join-Path $work "$label-run.json"
    $record = Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json
    $ownedProcess = Get-Process -Id $record.pid -ErrorAction SilentlyContinue
    if ($ownedProcess) {
        $age = ($ownedProcess.StartTime.ToUniversalTime() - [DateTime]::Parse($record.started_utc).ToUniversalTime()).TotalSeconds
        if ($ownedProcess.ProcessName -ne 'gzdoom' -or $age -lt -1 -or $age -gt 60) {
            throw "The recorded PID for $label has been reused; do not touch that process."
        }
    }
    $timer = [Diagnostics.Stopwatch]::StartNew()
    while ($ownedProcess -and !$ownedProcess.HasExited) {
        $null = $ownedProcess.WaitForExit(1000)
        $logPath = Join-Path $work "$label.txt"
        if (Test-Path -LiteralPath $logPath) {
            $recent = Get-Content -LiteralPath $logPath -Raw -Encoding utf8
            if ($recent -match 'Script error,|VM execution aborted|Unable to resolve all fields|Unbalanced|CA121 unbalanced|CA121 GUARD_MISMATCH') {
                Stop-Process -Id $record.pid -ErrorAction SilentlyContinue
                throw "$label failed in the native engine; retain its original log."
            }
        }
        if ($timer.Elapsed.TotalMinutes -gt 35) {
            Stop-Process -Id $record.pid -ErrorAction SilentlyContinue
            throw "$label exceeded the diagnostic deadline; it is not a completed measurement."
        }
    }
    $raw = [IO.File]::ReadAllText((Join-Path $work "$label.txt"))
    $ticks = @([regex]::Matches($raw, 'CA121 SIM tic=(\d+)') | ForEach-Object { [int]$_.Groups[1].Value })
    if (!$ticks.Count -or $ticks[-1] -lt $minimumTic) { throw "$label did not complete tic $minimumTic." }
    $benchmark = Join-Path $work 'benchmarks.txt'
    if (Test-Path -LiteralPath $benchmark) {
        $bytes = [IO.File]::ReadAllBytes($benchmark)
        $start = [int]$record.benchmark_offset
        [IO.File]::WriteAllBytes((Join-Path $work "$label-benchmarks.txt"), [byte[]]$bytes[$start..($bytes.Length-1)])
    }
    $record | Add-Member -NotePropertyName completed_utc -NotePropertyValue ([DateTime]::UtcNow.ToString('o')) -Force
    $record | Add-Member -NotePropertyName last_sim_tic -NotePropertyValue $ticks[-1] -Force
    $record | ConvertTo-Json -Depth 8 | Set-Content -Encoding utf8 -LiteralPath $metadataPath
    foreach ($suffix in @('.txt','.ini','-run.json','-benchmarks.txt')) {
        $source = Join-Path $work ($label+$suffix)
        if (Test-Path -LiteralPath $source) { Copy-Item -LiteralPath $source -Destination (Join-Path $PSScriptRoot ($label+$suffix)) }
    }
    Write-Output "COMPLETED $label through tic $($ticks[-1])"
}
if ($AttachLabel) { Complete-Run $AttachLabel 3500 }
elseif (!$StartAt) {
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Engine $Engine -Iwad $Iwad -Label 'baseline-b' -Package 'baseline.pk3' -Addon 'observer.pk3' -Script 'long.cfg'
    Complete-Run 'baseline-b' 3500
}
$runs = @(
    @('instrument-a','instrumented.pk3','instrument-observer.pk3','long.cfg',3500),
    @('instrument-b','instrumented.pk3','instrument-observer.pk3','matched.cfg',2100),
    @('baseline-c','baseline.pk3','observer.pk3','matched.cfg',2100),
    @('formation100-e','formation.pk3','formation-observer.pk3','formation-100.cfg',1715),
    @('formation1-a','formation.pk3','formation-observer.pk3','formation-1.cfg',1715),
    @('formation1-b','formation.pk3','formation-observer.pk3','formation-1.cfg',1715),
    @('formation100-f','formation.pk3','formation-observer.pk3','formation-100.cfg',1715),
    @('shared-a','shared-target.pk3','instrument-observer.pk3','matched.cfg',2100),
    @('shared-b','shared-target.pk3','instrument-observer.pk3','matched.cfg',2100),
    @('events-a','eventprobe.pk3','instrument-observer.pk3','matched.cfg',2100),
    @('guard-check-a','guard-check.pk3','instrument-observer.pk3','matched.cfg',2100),
    @('guards-a','spatial-guards.pk3','instrument-observer.pk3','matched.cfg',2100),
    @('cannon-a','cannon-retry.pk3','instrument-observer.pk3','matched.cfg',2100),
    @('formation-retry-a','formation-retry.pk3','formation-observer.pk3','formation-100.cfg',1715),
    @('shared-guards-a','shared-guards.pk3','instrument-observer.pk3','matched.cfg',2100),
    @('combined-a','combined.pk3','instrument-observer.pk3','long.cfg',3500),
    @('combined-b','combined.pk3','instrument-observer.pk3','long.cfg',3500),
    @('formation-retry-b','formation-retry.pk3','formation-observer.pk3','formation-100.cfg',1715),
    @('formation-all-a','formation-all.pk3','formation-observer.pk3','formation-100.cfg',1715),
    @('formation-all-b','formation-all.pk3','formation-observer.pk3','formation-100.cfg',1715)
)
$started = !$StartAt
foreach ($run in $runs) {
    if ($run[0] -eq $StartAt) { $started = $true }
    if (!$started) { continue }
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Engine $Engine -Iwad $Iwad -Label $run[0] -Package $run[1] -Addon $run[2] -Script $run[3]
    Complete-Run $run[0] $run[4]
}
if (!$started) { throw "Unknown run label: $StartAt" }
