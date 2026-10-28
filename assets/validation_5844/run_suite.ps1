param([string]$Prefix='release',[string]$Runtime='final44b',[switch]$SkipCatalogue)
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot 'run_native.ps1'
foreach($case in @('catalogue','craft','trade','items','reject','seed','hub','input','view0','view1','icon0','icon1')){
    if($SkipCatalogue -and $case -eq 'catalogue'){continue}
    & $runner -Label "$Prefix-$case" -Script $case -Runtime $Runtime -Checks -Language es
}
& $runner -Label "$Prefix-resume" -Script resume -Runtime $Runtime -LoadGame decor-current.zds -Checks
& $runner -Label "$Prefix-upgrade" -Script priorload -Runtime $Runtime -LoadGame decor-prior43.zds -Addon legacy-checks.pk3 -Checks
& $runner -Label "$Prefix-rollback" -Script priorload -Runtime prior43 -LoadGame decor-prior43.zds -Addon legacy-checks.pk3 -Checks
