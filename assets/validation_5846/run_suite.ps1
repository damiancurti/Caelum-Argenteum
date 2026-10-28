param([string]$Runtime='final46e',[string]$Prefix='release')
$ErrorActionPreference='Stop'
foreach($case in @('core','exposure','clock','warm','guards','production','resident','lethal','seed','perf','captureperf')) {
    & "$PSScriptRoot/run_native.ps1" -Label "$Prefix-$case" -Runtime $Runtime -Script $case -Checks -TimeoutSeconds 180
}
& "$PSScriptRoot/run_native.ps1" -Label "$Prefix-resume" -Runtime $Runtime -Script resume -LoadGame absent-current.zds -Checks
& "$PSScriptRoot/run_native.ps1" -Label "$Prefix-upgrade" -Runtime $Runtime -Script upgrade -Addon 'bridge/legacy-checks.pk3' -LoadGame absent-prior45b.zds -Checks
& "$PSScriptRoot/run_native.ps1" -Label "$Prefix-rollback" -Runtime '../../../issue502-contact-work/build/issue502-contact/final45a' -Addon legacy-checks.pk3 -Script legacyload -LoadGame absent-prior45b.zds -Checks
