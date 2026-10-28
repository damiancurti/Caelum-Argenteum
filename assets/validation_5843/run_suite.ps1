param([string]$Prefix='release',[string]$Runtime='final43b')
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot 'run_native.ps1'
$cases=@(
    @{Label='seed';Script='seed';StartMap='MAP03'},
    @{Label='reload';Script='reload';LoadGame='away-back.zds'},
    @{Label='resume';Script='resume';LoadGame='away-active.zds'},
    @{Label='limbo';Script='limbo';LoadGame='away-home.zds'},
    @{Label='core';Script='core';LoadGame='away-home.zds'},
    @{Label='shortages';Script='shortages';LoadGame='away-home.zds'},
    @{Label='multiple';Script='multiple';LoadGame='away-home.zds'},
    @{Label='migration';Script='migration';LoadGame='home-prior42.zds'}
)
foreach($case in $cases){$case.Label="$Prefix-$($case.Label)"; & $runner @case -Runtime $Runtime -Checks -TimeoutSeconds 55}
& $runner -Label "$Prefix-rollback" -Script rollback -Runtime prior42 -LoadGame home-prior42.zds -Addon legacy-checks.pk3 -Checks
& $runner -Label "$Prefix-frames-prior" -Script frames -Runtime prior42 -LoadGame home-prior42.zds -Addon legacy-frames.pk3 -Checks -TimeoutSeconds 55
& $runner -Label "$Prefix-frames-current" -Script frames -Runtime $Runtime -LoadGame home-prior42.zds -Addon frames.pk3 -Checks -TimeoutSeconds 55
