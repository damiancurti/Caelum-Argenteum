param([switch]$WaitForPrevious, [string]$RecoverySave = '')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build/issue133'
Set-Location -LiteralPath $repo
if ($WaitForPrevious) {
    $record = Get-Content -LiteralPath (Join-Path $work 'route-fresh-ground-run.json') -Raw | ConvertFrom-Json
    $owned = Get-Process -Id $record.pid -ErrorAction SilentlyContinue
    if ($owned) {
        if ($owned.ProcessName -ne 'gzdoom' -or [Math]::Abs(($owned.StartTime.ToUniversalTime()-[DateTime]::Parse($record.started_utc).ToUniversalTime()).TotalSeconds) -gt 60) { throw 'Previous PID is not the owned engine.' }
        while (!$owned.HasExited) { $null = $owned.WaitForExit(1000) }
    }
}
python -X utf8 assets/validation_513/prepare.py
if ($LASTEXITCODE) { throw 'Production preparation failed.' }
python -X utf8 assets/validation_513/prepare_legacy.py
if ($LASTEXITCODE) { throw 'Persistence preparation failed.' }
python -X utf8 assets/validation_513/prepare_performance.py
if ($LASTEXITCODE) { throw 'Performance preparation failed.' }
& (Join-Path $repo 'build_dev.ps1') -LegacyMap06SouthCity -Destination build/issue133/upgrade/baseline.pk3
if ($LASTEXITCODE) { throw 'Compatible package build failed.' }
$run = Join-Path $PSScriptRoot 'run_check.ps1'
if ($RecoverySave) {
    'wait 3500; save route-crew-final; wait 10; quit' | Set-Content -LiteralPath (Join-Path $work 'route-crew-final.cfg') -Encoding ascii
    & $run -Label route-crew-final-b -Addon routes.pk3 -LoadGame $RecoverySave -Script route-crew-final.cfg -Expected 'CA133 ROUTE_VERIFIED'
}
if (!(Test-Path -LiteralPath (Join-Path $work 'ca133-legacy-original.zds'))) {
    & $run -Label final-legacy-seed -Package baseline.pk3 -Addon legacy.pk3 -Script legacy-seed.cfg -Expected 'CA133 LEGACY_SEEDED'
}
'wait 35000; save route-delivery; wait 10; quit' | Set-Content -LiteralPath (Join-Path $work 'route-delivery.cfg') -Encoding ascii
& $run -Label route-delivery -Addon routes.pk3 -Script route-delivery.cfg -Expected 'CA133 ROUTE_VERIFIED'
python -X utf8 assets/validation_513/prepare_replacement.py
if ($LASTEXITCODE) { throw 'Replacement control preparation failed.' }
& $run -Label final-replacement -Addon replacement/routes.pk3 -LoadGame route-delivery.zds -Script replacement.cfg -Expected 'CA133 REPLACEMENT_COMPLETE elapsed=\d+ failures=0'
& $run -Label final-checks -Addon checks.pk3 -Script checks.cfg
& $run -Label final-carbine -Addon carbine.pk3 -Map CA133 -Script carbine.cfg
& $run -Label final-deployment-save -Addon deployment.pk3 -Script deployment-save.cfg -Expected 'CA133 DEPLOYMENT_SEEDED'
& $run -Label final-deployment-reload -Addon deployment.pk3 -Script deployment-reload.cfg -LoadGame ca133-deployment.zds -Expected 'CA133 DEPLOYMENT_PERSIST_COMPLETE failures=0'
& $run -Label final-deployment-hub -Addon deployment.pk3 -Script deployment-hub.cfg -LoadGame ca133-deployment.zds -Expected 'CA133 DEPLOYMENT_PERSIST_COMPLETE failures=0'
& $run -Label final-legacy-upgrade -Package upgrade/baseline.pk3 -Addon legacy.pk3 -Script legacy-upgrade.cfg -LoadGame ca133-legacy-original.zds -Expected 'CA133 LEGACY_COMPLETE'
& $run -Label final-legacy-hub -Package upgrade/baseline.pk3 -Addon legacy.pk3 -Script legacy-hub.cfg -LoadGame ca133-legacy-upgraded.zds -Expected 'CA133 LEGACY_COMPLETE'
& $run -Label final-obstruction -Addon obstruction.pk3 -Script obstruction.cfg -Expected 'CA133 OBSTRUCTION_COMPLETE failures=0'
& $run -Label delivery-trade -Addon trade.pk3 -Script trade-save.cfg
& $run -Label delivery-trade-reload -Addon trade.pk3 -Script trade-reload.cfg -LoadGame ca133-city-original.zds -Expected 'CA133 PERSIST_COMPLETE'
& $run -Label delivery-trade-hub -Addon trade.pk3 -Script trade-hub.cfg -LoadGame ca133-city-original.zds -Expected 'CA133 PERSIST_COMPLETE'
& $run -Label delivery-furniture -Addon furniture.pk3 -Script furniture.cfg
& $run -Label delivery-factories -Addon factories.pk3 -Script trade.cfg
& $run -Label manual-smoke -Addon manual.pk3 -Script manual-smoke.cfg -Expected 'CA133 MANUAL_DATE_SET'
python -X utf8 assets/validation_513/prepare_visual.py final-visual
if ($LASTEXITCODE) { throw 'Visual command preparation failed.' }
& $run -Label final-visual -Addon visual.pk3 -Script visual-sweep.cfg -Language es -Expected 'CA133 VISUAL scene=4 ready'
& $run -Label final-player-shot -Addon visual.pk3 -Script player-shot.cfg -Expected 'CA133 PLAYER_VISUAL .*frame=3 magazine=9'
& $run -Label perf-legacy-full -Package upgrade/baseline.pk3 -Addon observer.pk3 -Staged 0 -Script performance.cfg -Expected 'CA132 PERFORMANCE COMPLETE' -MinimumTic 3500
& $run -Label perf-legacy-staged -Package upgrade/baseline.pk3 -Addon observer.pk3 -Staged 1 -Script performance.cfg -Expected 'CA132 PERFORMANCE COMPLETE' -MinimumTic 3500
& $run -Label perf-city-staged -Addon combined.pk3 -Script combined.cfg -Expected 'CA132 PERFORMANCE COMPLETE' -MinimumTic 10500
& $run -Label perf-volleys -Addon volleys.pk3 -Script performance.cfg -Expected 'CA133 VOLLEY_COMPLETE'
'wait 500; save volley-500; wait 950; save volley-1450; wait 5; quit' | Set-Content -LiteralPath (Join-Path $work 'volley-cause.cfg') -Encoding ascii
& $run -Label volley-cause -Addon volleys.pk3 -Script volley-cause.cfg -Expected 'CA133 VOLLEY tic=1435'
python -X utf8 assets/validation_513/record_heat_limit.py
if ($LASTEXITCODE) { throw 'Thermal snapshot analysis failed.' }
python -X utf8 assets/validation_513/analyze_performance.py
if ($LASTEXITCODE) { throw 'Performance analysis failed.' }
