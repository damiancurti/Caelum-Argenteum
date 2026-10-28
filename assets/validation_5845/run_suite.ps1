param([string]$Runtime='final45a',[string]$Prefix='release')
$ErrorActionPreference='Stop'
foreach($case in @('core','input','seed','hub')) {
    & "$PSScriptRoot\run_native.ps1" -Label "$Prefix-$case" -Runtime $Runtime -Script $case -Checks
}
& "$PSScriptRoot\run_native.ps1" -Label "$Prefix-resume" -Runtime $Runtime -Script resume -LoadGame contact-current.zds -Checks
& "$PSScriptRoot\run_native.ps1" -Label "$Prefix-upgrade" -Runtime $Runtime -Script upgrade -LoadGame contact-prior44.zds -Checks
& "$PSScriptRoot\run_native.ps1" -Label "$Prefix-rollback" -Runtime prior44 -Addon legacy-checks.pk3 -Script legacyload -LoadGame contact-prior44.zds -Checks
