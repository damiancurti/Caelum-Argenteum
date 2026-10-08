param([Parameter(Mandatory=$true)][string]$Prefix, [switch]$FullDeployment)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $repo
foreach ($script in @('prepare.py','prepare_sweat.py','prepare_performance.py','prepare_sweat_saves.py')) {
    python -X utf8 (Join-Path $PSScriptRoot $script)
    if ($LASTEXITCODE) { throw "Preparation failed: $script" }
}
$run = Join-Path $PSScriptRoot 'run_check.ps1'
& $run -Label "$Prefix-math" -Addon sweat.pk3 -Map CA133 -Script sweat.cfg -Expected 'CA133 SWEAT_COMPLETE checks=\d+ failures=0'
& $run -Label "$Prefix-reload" -Addon sweat.pk3 -LoadGame sweat-current.zds -Script sweat-reload.cfg -Expected 'CA133 SWEAT_RELOAD checks=1 failures=0'
& $run -Label "$Prefix-hub" -Addon sweat.pk3 -LoadGame sweat-current.zds -Script sweat-hub.cfg -Expected 'CA133 SWEAT_RELOAD checks=1 failures=0 reopen=1'
& $run -Label "$Prefix-old" -Package sweat-old/production.pk3 -Addon sweat-old/sweat-migration.pk3 -Map CA133 -Script sweat-seed.cfg -Expected 'CA133 SWEAT_SEED revision=2'
& $run -Label "$Prefix-upgrade" -Package sweat-new/production.pk3 -Addon sweat-new/sweat-migration.pk3 -LoadGame sweat-original.zds -Script sweat-upgrade.cfg -Expected 'CA133 SWEAT_UPGRADE failures=0'
& $run -Label "$Prefix-upgrade-reload" -Package sweat-new/production.pk3 -Addon sweat-new/sweat-migration.pk3 -LoadGame sweat-upgraded.zds -Script sweat-rollback.cfg -Expected 'CA133 SWEAT_UPGRADE failures=0'
& $run -Label "$Prefix-rollback" -Package sweat-old/production.pk3 -Addon sweat-old/sweat-migration.pk3 -LoadGame sweat-original.zds -Script sweat-rollback.cfg -Expected 'CA133 SWEAT_OLD_LOAD failures=0'
& $run -Label "$Prefix-carbine" -Addon carbine.pk3 -Map CA133 -Script carbine.cfg
& $run -Label "$Prefix-volleys" -Addon volleys.pk3 -Script sweat-volley.cfg -Expected 'CA133 VOLLEY_COMPLETE' -MinimumTic 3500
& $run -Label "$Prefix-city" -Addon combined.pk3 -Script sweat-combined.cfg -Expected 'CA133 CITY tic=10500' -MinimumTic 10500
if ($FullDeployment) {
    'wait 35000; save sweat-route-final; wait 10; quit' | Set-Content -LiteralPath build/issue133/sweat-routes.cfg -Encoding ascii
    & $run -Label "$Prefix-routes" -Addon routes.pk3 -Script sweat-routes.cfg -Expected 'CA133 ROUTE_VERIFIED'
}
python -X utf8 (Join-Path $PSScriptRoot 'analyze_sweat.py') "$Prefix-volleys" "$Prefix-city"
if ($LASTEXITCODE) { throw 'Sweat result analysis failed.' }
