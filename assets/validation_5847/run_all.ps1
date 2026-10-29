param([string]$Runtime='final47b',[string]$Prefix='repeat')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path "$PSScriptRoot/../..").Path
python "$PSScriptRoot/prepare.py"
foreach($case in @('core','native','exposure','contact','storage','catalogue','npc','merchant','rebase','perf','seed','hub')) {
    & "$PSScriptRoot/run_native.ps1" -Label "$Prefix-$case" -Runtime $Runtime -Script $case -Checks
}
foreach($case in @('ground','groundlive')) {
    & "$PSScriptRoot/run_native.ps1" -Label "$Prefix-$case" -Runtime $Runtime -Script $case -StartMap MAP01 -Checks
}
& "$PSScriptRoot/run_native.ps1" -Label "$Prefix-resume" -Runtime $Runtime -Script resume -LoadGame stack-current.zds -Checks
& "$PSScriptRoot/run_native.ps1" -Label "$Prefix-upgrade" -Runtime $Runtime -Script upgrade -LoadGame stack-prior46.zds -Addon 'bridge/legacy-checks.pk3' -Checks
python "$repo/assets/validation_5846/prepare.py"
python "$repo/assets/validation_5817/prepare.py"
foreach($case in @('core','exposure','production')) {
    & "$repo/assets/validation_5846/run_native.ps1" -Label "$Prefix-absence-$case" -Runtime "../issue502-stackables/$Runtime" -Script $case -Checks
}
foreach($case in @('k-transfer','k-pickup','k-market')) {
    & "$repo/assets/validation_5817/run_native.ps1" -Label "$Prefix-food-$case" -Runtime "../issue502-stackables/$Runtime" -Script $case -Checks
}
