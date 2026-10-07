param([ValidateSet('fresh','reload','transactions','pickups','performance','repeat','projection','creation')][string]$Group='fresh', [string]$Suffix='final')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work=Join-Path $repo 'build\issue120'
$runs=@()
if($Group -eq 'fresh'){
    foreach($domain in @('player','inventory','tarot')){
        foreach($label in @('baseline','current')){
            $runs+=@{Label="$domain-$label";Package="$label.pk3";Addon="$domain/checks.pk3";Map='MAP01';Script="$domain-$label.cfg"}
        }
    }
}
if($Group -eq 'reload'){
    foreach($domain in @('player','inventory','tarot')){
        $runs+=@{Label="$domain-old-save";Package='current-runtime/baseline.pk3';Addon="$domain/checks.pk3";LoadGame="ca120_${domain}_baseline_hub.zds";Script="$domain-reload.cfg"}
        $runs+=@{Label="$domain-new-save";Package='current.pk3';Addon="$domain/checks.pk3";LoadGame="ca120_${domain}_current_hub.zds";Script='reload-only.cfg'}
        $runs+=@{Label="$domain-upgraded-save";Package='current-runtime/baseline.pk3';Addon="$domain/checks.pk3";LoadGame="ca120_${domain}_upgraded.zds";Script='reload-only.cfg'}
        $runs+=@{Label="$domain-original-rollback";Package='baseline.pk3';Addon="$domain/checks.pk3";LoadGame="ca120_${domain}_baseline_hub.zds";Script='reload-only.cfg'}
    }
}
if($Group -in @('transactions','pickups')){
    foreach($action in @('transactions','pickups')){
        if($Group -eq 'pickups' -and $action -ne 'pickups'){continue}
        foreach($label in @('baseline','current')){
            $runs+=@{Label="$action-$label";Package="$label.pk3";Addon='inventory/checks.pk3';Map=$(if($action -eq 'pickups'){'MAP03'}else{'MAP01'});Script="$action.cfg"}
        }
    }
}
if($Group -eq 'creation'){
    foreach($language in @('enu','es')){
        $runs+=@{Label="creation-$language";Package='current.pk3';Addon='creation.pk3';Map='MAP03';Language=$language;Script="creation-$language.cfg"}
    }
}
if($Group -eq 'projection'){
    $runs=@(
        @{Label='architecture1-old-save';Package='current-runtime/after-final.pk3';LoadGame='ca116_snapshot.zds';Script='projection-reload.cfg'},
        @{Label='architecture1-upgraded-save';Package='current-runtime/after-final.pk3';LoadGame='ca120_projection_upgraded.zds';Script='reload-only.cfg'},
        @{Label='architecture1-original-rollback';Package='original-runtime/after-final.pk3';LoadGame='ca116_snapshot.zds';Script='reload-only.cfg'}
    )
    foreach($run in $runs){$run.Addon='projection/checks.pk3'}
}
if($Group -eq 'performance'){
    $runs=@(@{Label='architecture1-performance';Package='architecture1.pk3'},@{Label='current-performance';Package='current.pk3'})
}
if($Group -eq 'repeat'){
    $runs=@(@{Label='current-performance-repeat';Package='current.pk3'},@{Label='architecture1-performance-repeat';Package='architecture1.pk3'})
}
foreach($run in $runs){
    $run.Label=$run.Label+'-'+$Suffix
    if($Group -in @('performance','repeat')){$run.Addon='benchmark.pk3';$run.Map='MAP06';$run.Script='benchmark.cfg'}
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
    if($log -match 'CA(?:116|117|118|119|120) FAIL|Script error|VM execution aborted|needs these files|FATAL ERROR'){throw "Fixture failed: $($run.Label)"}
    Write-Output "Completed $($run.Label)"
}
