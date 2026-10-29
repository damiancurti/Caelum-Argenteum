param([string]$Runtime='final49a',[string]$Prefix='ready49')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path "$PSScriptRoot/../..").Path
python "$PSScriptRoot/prepare.py"
if($LASTEXITCODE -ne 0){throw 'Fixture preparation failed'}
foreach($case in @('catalogue','food','forecast','contact','support','absent','seed')) {
    & "$PSScriptRoot/run_native.ps1" -Label "$Prefix-$case" -Runtime $Runtime -Script $case -Checks
}
& "$PSScriptRoot/run_native.ps1" -Label "$Prefix-resume" -Runtime $Runtime -Script resume -LoadGame physical-current.zds -Checks
& "$PSScriptRoot/run_native.ps1" -Label "$Prefix-hub" -Runtime $Runtime -Script hub -Checks
& "$PSScriptRoot/run_native.ps1" -Label "$Prefix-upgrade" -Runtime $Runtime -Script resume -LoadGame physical-prior48.zds -Addon bridge/legacy-checks.pk3 -Checks
& "$PSScriptRoot/run_native.ps1" -Label "$Prefix-rollback" -Runtime original48 -Script legacyload -LoadGame physical-prior48.zds -Addon legacy-checks.pk3 -Checks
foreach($case in @('k-transfer','k-pickup','k-market','f-clock')) {
    & "$repo/assets/validation_5817/run_native.ps1" -Label "$Prefix-$case" -Runtime "../issue502-physical/$Runtime" -Script $case -Checks
}
foreach($case in @('process-core','process-guards','process-fast')) {
    & "$repo/assets/validation_5819/run_native.ps1" -Label "$Prefix-$case" -Runtime "../issue502-physical/$Runtime" -Script $case -Addon process-checks.pk3 -Checks
}
