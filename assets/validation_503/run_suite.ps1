# Native runs are serial and use only the PID created by this runner.
param([ValidateSet('checks','performance','repeat','menus')][string]$Group = 'checks', [string]$Suffix = 'final', [switch]$SkipFresh)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build\issue119'
$runs = @(
    @{Label='baseline-tarot';Package='baseline.pk3';Script='baseline.cfg'},
    @{Label='current-tarot';Package='current.pk3';Script='current.cfg'},
    @{Label='old-save-current';Package='current-runtime/baseline.pk3';LoadGame='ca119_baseline_hub.zds';Script='reload.cfg'},
    @{Label='current-save-reload';Package='current.pk3';LoadGame='ca119_current_hub.zds';Script='reload-only.cfg'},
    @{Label='upgraded-save-reload';Package='current-runtime/baseline.pk3';LoadGame='ca119_upgraded.zds';Script='reload-only.cfg'},
    @{Label='original-save-rollback';Package='baseline.pk3';LoadGame='ca119_baseline_hub.zds';Script='reload-only.cfg'},
    @{Label='tarot-ui-enu';Package='current.pk3';Script='ui-enu.cfg';Language='enu'},
    @{Label='tarot-ui-es';Package='current.pk3';Script='ui-es.cfg';Language='es'}
)
if($Group -eq 'performance'){
    $runs=@(@{Label='baseline-performance';Package='baseline.pk3';Script='benchmark.cfg'},@{Label='current-performance';Package='current.pk3';Script='benchmark.cfg'})
}
if($Group -eq 'repeat'){
    $runs=@(@{Label='current-performance-repeat';Package='current.pk3';Script='benchmark.cfg'},@{Label='baseline-performance-repeat';Package='baseline.pk3';Script='benchmark.cfg'})
}
if($Group -eq 'menus'){
    $runs=@(
        @{Label='baseline-menus';Package='baseline.pk3';Script='menus-baseline-enu.cfg'},
        @{Label='current-menus-enu';Package='current.pk3';Script='menus-current-enu.cfg'},
        @{Label='current-menus-es';Package='current.pk3';Script='menus-current-es.cfg';Language='es'},
        @{Label='old-trucazo-menu';Package='current-runtime/baseline.pk3';LoadGame='ca119_baseline_tc.zds';Script='menu-reload-tc.cfg'},
        @{Label='old-truco-menu';Package='current-runtime/baseline.pk3';LoadGame='ca119_baseline_tr.zds';Script='menu-reload-tr.cfg'}
    )
}
foreach($run in $runs){
    if($SkipFresh -and $run.Label -in @('baseline-tarot','current-tarot')){continue}
    $run.Label=$run.Label+'-'+$Suffix
    if($Group -in @('checks','menus')){$run.Addon='checks.pk3';$run.Map='MAP01'}
    else{$run.Addon='benchmark.pk3';$run.Map='MAP06'}
    & (Join-Path $PSScriptRoot 'run_native.ps1') @run
    $metadata=Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $work ($run.Label+'-run.json')) | ConvertFrom-Json
    $started=[DateTime]::UtcNow
    while(Get-Process -Id $metadata.pid -ErrorAction SilentlyContinue){
        $logPath=Join-Path $work ($run.Label+'.txt')
        if((Test-Path -LiteralPath $logPath) -and ((Get-Content -Raw -LiteralPath $logPath) -match 'FATAL ERROR|Script error|VM execution aborted')){
            Stop-Process -Id $metadata.pid;throw "Native error: $($run.Label)"
        }
        if(([DateTime]::UtcNow-$started).TotalSeconds -gt 360){Stop-Process -Id $metadata.pid;throw "Fixture timeout: $($run.Label)"}
        Start-Sleep -Seconds 1
    }
    $log=Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $work ($run.Label+'.txt'))
    if($log -match 'CA119 FAIL|Script error|VM execution aborted|needs these files|FATAL ERROR'){throw "Fixture failed: $($run.Label)"}
    Write-Output "Completed $($run.Label)"
}
