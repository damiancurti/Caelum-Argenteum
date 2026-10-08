$ErrorActionPreference = 'Stop'
$runner = Join-Path $PSScriptRoot 'run_check.ps1'
$jobs = @(
    @{ Label='baseline-natural-b'; Package='baseline.pk3'; Addon='baseline-observer.pk3'; Staged=0; Script='natural-final.cfg'; Capture=$true; Expected='CA132 PERFORMANCE COMPLETE tic=3500' },
    @{ Label='cap-natural-b'; Addon='cap-observer.pk3'; Script='natural.cfg'; Capture=$true; Expected='CA132 PERFORMANCE COMPLETE tic=3500' },
    @{ Label='profile-full-a'; Package='profile-baseline.pk3'; Addon='baseline-observer.pk3'; Staged=0; Script='profile.cfg'; Expected='CA132 PERFORMANCE COMPLETE tic=700' },
    @{ Label='profile-cap-a'; Package='profile-production.pk3'; Addon='cap-observer.pk3'; Script='profile.cfg'; Expected='CA132 PERFORMANCE COMPLETE tic=700' },
    @{ Label='profile-late-a'; Package='profile/production.pk3'; Addon='observer.pk3'; LoadGame='final-late.zds'; Script='profile-late.cfg'; Expected='CA121 COST' },
    @{ Label='profile-deaths-a'; Package='profile/baseline.pk3'; Addon='baseline-observer.pk3'; Staged=0; LoadGame='baseline-pre-collapse.zds'; Script='profile-deaths.cfg'; Expected='CA132 DEATH COMPLETE' }
)
foreach ($job in $jobs) { & $runner @job }
