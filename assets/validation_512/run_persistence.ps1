$ErrorActionPreference = 'Stop'
$runner = Join-Path $PSScriptRoot 'run_check.ps1'
$jobs = @(
    @{ Label='final-boundaries'; Script='checks-final.cfg'; Addon='checks.pk3'; Expected='CA132 COMPLETE checks=22 failures=0' },
    @{ Label='final-pending-reload'; Script='checks-final-reload.cfg'; Addon='checks.pk3'; LoadGame='final-pending-group.zds'; Expected='CA132 COMPLETE checks=22 failures=0' },
    @{ Label='old-save'; Script='old-save.cfg'; Package='baseline.pk3'; Addon='baseline-observer.pk3'; Staged=0; Expected='CA132 SIM' },
    @{ Label='old-upgrade-b'; Script='old-upgrade.cfg'; Package='upgrade/baseline.pk3'; Addon='baseline-observer.pk3'; LoadGame='original-full-army.zds'; Expected='CA132 SIM' },
    @{ Label='old-rollback'; Script='old-rollback.cfg'; Package='baseline.pk3'; Addon='baseline-observer.pk3'; Staged=0; LoadGame='original-full-army.zds'; Expected='CA132 SIM' },
    @{ Label='stage-save'; Script='stage-save.cfg'; Addon='observer.pk3'; Expected='CA132 SIM' },
    @{ Label='stage-reload'; Script='stage-reload.cfg'; Addon='observer.pk3'; LoadGame='staged-cadence.zds'; Expected='CA132 SIM' },
    @{ Label='stage-hub'; Script='stage-hub.cfg'; Addon='observer.pk3'; LoadGame='staged-cadence.zds'; Expected='CA132 SIM' }
)
foreach ($job in $jobs) { & $runner @job }
