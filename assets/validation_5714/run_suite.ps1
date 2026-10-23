param([string]$Prefix='final01',[string]$Runtime='current')
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot 'run_native.ps1'
foreach($case in @('basics','transactions','crafting','catalogue','recovery','transfer','keys','seed')) {
    & $runner -Label "$Prefix-$case" -Runtime $Runtime -Checks -Script $case
}
& $runner -Label "$Prefix-resume" -Runtime $Runtime -Checks -Script resume -LoadGame mate472.zds
& $runner -Label "$Prefix-travel" -Runtime $Runtime -Checks -Script mate-travel
& $runner -Label "$Prefix-old-load" -Runtime $Runtime -Checks -Addon 'migrated/legacy-checks.pk3' -Script legacy-resume -LoadGame old471.zds
foreach($variant in 0..2) { & $runner -Label "$Prefix-visual$variant" -Runtime $Runtime -Checks -Script "visual$variant" }
& $runner -Label "$Prefix-workshop" -Runtime $Runtime -Checks -Script workshop
& $runner -Label "$Prefix-map" -Runtime $Runtime -Checks -Script map -StartMap MAP03
Write-Output "Completed $Prefix without native assertion failures."
