param([string]$Runtime='final46e',[string]$Prefix='final46')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path "$PSScriptRoot/../..").Path
python "$repo/assets/validation_5838/prepare.py"
python "$repo/assets/validation_5843/prepare.py"
foreach($case in @('core','recovery')) {
 & "$repo/assets/validation_5838/run_native.ps1" -Label "$Prefix-active-$case" -Runtime "../issue502-unloaded-npc/$Runtime" -Script $case -Checks
}
& "$repo/assets/validation_5843/run_native.ps1" -Label "$Prefix-home-seed" -Runtime "../issue502-unloaded-npc/$Runtime" -Script seed -StartMap MAP03 -Checks -TimeoutSeconds 90
foreach($case in @('core','shortages','limbo')) {
 & "$repo/assets/validation_5843/run_native.ps1" -Label "$Prefix-home-$case" -Runtime "../issue502-unloaded-npc/$Runtime" -Script $case -LoadGame away-home.zds -Checks -TimeoutSeconds 90
}
