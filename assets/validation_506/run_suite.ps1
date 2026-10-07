param([string]$Labels = 'baseline-a,current-a,no-stagger-a,no-candidates-a,neither-a,neither-b,no-candidates-b,no-stagger-b,current-b')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build\issue128'
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
            if ($recent -match 'Script error,|VM execution aborted|Unable to resolve all fields|Unbalanced|CA121 unbalanced|CA121 GUARD_MISMATCH|CA128 FAIL') {
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
foreach ($label in $Labels.Split(',')) {
    $package = $label.Substring(0,$label.LastIndexOf('-')) + '.pk3'
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Label $label -Package $package -Script 'long.cfg'
    Complete-Run $label 3500
}
