param([string]$Runtime='final48',[string]$Prefix='ready48')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path "$PSScriptRoot/../..").Path
python "$PSScriptRoot/prepare.py"
if($LASTEXITCODE -ne 0){throw 'Fixture preparation failed'}
foreach($case in @('catalogue','storage','immersion','camp','packed','contact','seed')) {
    & "$PSScriptRoot/run_native.ps1" -Label "$Prefix-$case" -Runtime $Runtime -Script $case -Checks
}
& "$PSScriptRoot/run_native.ps1" -Label "$Prefix-resume" -Runtime $Runtime -Script resume -LoadGame vessel-current.zds -Checks
foreach($case in @('hub','awaysave','packedtravel')) {
    & "$PSScriptRoot/run_native.ps1" -Label "$Prefix-$case" -Runtime $Runtime -Script $case -Checks
}
& "$PSScriptRoot/run_native.ps1" -Label "$Prefix-awayload" -Runtime $Runtime -Script resume -LoadGame vessel-away.zds -Checks
& "$PSScriptRoot/run_native.ps1" -Label "$Prefix-packedload" -Runtime $Runtime -Script packedresume -LoadGame vessel-packed.zds -Checks
& "$PSScriptRoot/run_native.ps1" -Label "$Prefix-upgrade" -Runtime $Runtime -Script upgrade -LoadGame vessel-prior47.zds -Addon bridge/legacy-checks.pk3 -Checks
python "$repo/assets/validation_5840/prepare.py"
if($LASTEXITCODE -ne 0){throw 'Dining fixture preparation failed'}
foreach($case in @('hub','nestedhub')) {
    & "$repo/assets/validation_5840/run_native.ps1" -Label "$Prefix-dining-$case" -Runtime "../issue502-vessels/$Runtime" -Script $case -Checks
}
python "$repo/assets/validation_5847/prepare.py"
if($LASTEXITCODE -ne 0){throw 'Stack fixture preparation failed'}
foreach($case in @('native','contact','storage','exposure','npc')) {
    & "$repo/assets/validation_5847/run_native.ps1" -Label "$Prefix-stacks-$case" -Runtime "../issue502-vessels/$Runtime" -Script $case -Checks
}
