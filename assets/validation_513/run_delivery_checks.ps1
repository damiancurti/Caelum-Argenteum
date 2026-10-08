param([string]$Prefix = 'delivery')
$ErrorActionPreference = 'Stop'
$run = Join-Path $PSScriptRoot 'run_check.ps1'
& $run -Label "$Prefix-legacy-seed" -Package baseline.pk3 -Addon legacy.pk3 -Script legacy-seed.cfg -Expected 'CA133 LEGACY_SEEDED'
& $run -Label "$Prefix-legacy-upgrade" -Package upgrade/baseline.pk3 -Addon legacy.pk3 -Script legacy-upgrade.cfg -LoadGame ca133-legacy-original.zds -Expected 'CA133 LEGACY_COMPLETE'
& $run -Label "$Prefix-legacy-reload" -Package upgrade/baseline.pk3 -Addon legacy.pk3 -Script legacy-reload.cfg -LoadGame ca133-legacy-upgraded.zds -Expected 'CA133 LEGACY_COMPLETE'
& $run -Label "$Prefix-legacy-hub" -Package upgrade/baseline.pk3 -Addon legacy.pk3 -Script legacy-hub.cfg -LoadGame ca133-legacy-upgraded.zds -Expected 'CA133 LEGACY_COMPLETE'
& $run -Label "$Prefix-legacy-rollback" -Package baseline.pk3 -Addon legacy.pk3 -Script legacy-reload.cfg -LoadGame ca133-legacy-original.zds -Expected 'CA133 LEGACY_COMPLETE'
& $run -Label "$Prefix-deployment-save" -Addon deployment.pk3 -Script deployment-save.cfg -Expected 'CA133 DEPLOYMENT_SEEDED'
& $run -Label "$Prefix-deployment-reload" -Addon deployment.pk3 -Script deployment-reload.cfg -LoadGame ca133-deployment.zds -Expected 'CA133 DEPLOYMENT_PERSIST_COMPLETE failures=0'
& $run -Label "$Prefix-deployment-hub" -Addon deployment.pk3 -Script deployment-hub.cfg -LoadGame ca133-deployment.zds -Expected 'CA133 DEPLOYMENT_PERSIST_COMPLETE failures=0'
& $run -Label "$Prefix-carbine" -Addon carbine.pk3 -Map CA133 -Script carbine.cfg
& $run -Label "$Prefix-obstruction" -Addon obstruction.pk3 -Script obstruction.cfg -Expected 'CA133 OBSTRUCTION_COMPLETE failures=0'
& $run -Label "$Prefix-trade" -Addon trade.pk3 -Script trade-save.cfg
& $run -Label "$Prefix-trade-reload" -Addon trade.pk3 -Script trade-reload.cfg -LoadGame ca133-city-original.zds -Expected 'CA133 PERSIST_COMPLETE'
& $run -Label "$Prefix-trade-hub" -Addon trade.pk3 -Script trade-hub.cfg -LoadGame ca133-city-original.zds -Expected 'CA133 PERSIST_COMPLETE'
& $run -Label "$Prefix-furniture" -Addon furniture.pk3 -Script furniture.cfg
& $run -Label "$Prefix-factories" -Addon factories.pk3 -Script trade.cfg
& $run -Label "$Prefix-visual" -Addon visual.pk3 -Script visual-sweep.cfg -Language es -Expected 'CA133 VISUAL scene=4 ready'
