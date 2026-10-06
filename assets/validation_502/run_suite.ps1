# Run the reviewed native schedules serially; all fixtures/packages remain local.
param([ValidateSet('checks','performance','repeat')][string]$Group = 'checks')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build\issue118'
$runs = @(
    @{Label='baseline-pickups-final';Package='baseline.pk3';Script='pickups.cfg'},
    @{Label='current-pickups';Package='current.pk3';Script='pickups.cfg'},
    @{Label='current-transactions-final';Package='current.pk3';Script='transactions.cfg'},
    @{Label='ownership-current';Package='current.pk3';Script='ownership.cfg'},
    @{Label='new-save-reload';Package='current.pk3';LoadGame='ca118_current_hub.zds';Script='reload-only.cfg'},
    @{Label='upgraded-save-reload';Package='current-runtime/baseline.pk3';LoadGame='ca118_upgraded.zds';Script='reload-only.cfg'},
    @{Label='original-save-rollback';Package='baseline.pk3';LoadGame='ca118_baseline_hub.zds';Script='reload-only.cfg'},
    @{Label='inventory-ui-final-enu';Package='current.pk3';Script='ui-enu.cfg';Language='enu'},
    @{Label='inventory-ui-final-es';Package='current.pk3';Script='ui-es.cfg';Language='es'}
)
if ($Group -eq 'performance') {
    $runs = @(
        @{Label='baseline-performance-locked';Package='baseline.pk3';Script='benchmark.cfg'},
        @{Label='current-performance-locked';Package='current.pk3';Script='benchmark.cfg'}
    )
}
if ($Group -eq 'repeat') {
    $runs = @(
        @{Label='current-performance-repeat';Package='current.pk3';Script='benchmark.cfg'},
        @{Label='baseline-performance-repeat';Package='baseline.pk3';Script='benchmark.cfg'}
    )
}
foreach ($run in $runs) {
    if ($Group -ne 'checks') {$run.Addon='benchmark.pk3';$run.Map='MAP06'}
    else {$run.Addon='checks.pk3';$run.Map='MAP03'}
    & (Join-Path $PSScriptRoot 'run_native.ps1') @run
    $metadata = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $work ($run.Label+'-run.json')) | ConvertFrom-Json
    $started = [DateTime]::UtcNow
    while (Get-Process -Id $metadata.pid -ErrorAction SilentlyContinue) {
        if (([DateTime]::UtcNow-$started).TotalSeconds -gt 360) {
            Stop-Process -Id $metadata.pid
            throw "Native fixture timed out: $($run.Label)"
        }
        Start-Sleep -Seconds 1
    }
    $log = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $work ($run.Label+'.txt'))
    if ($log -match 'CA118 FAIL|Script error|VM execution aborted|needs these files') {throw "Native fixture failed: $($run.Label)"}
    Write-Output "Completed $($run.Label)"
}
