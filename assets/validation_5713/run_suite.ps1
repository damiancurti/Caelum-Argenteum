param([string]$Prefix='integrated',[string]$Runtime='probe')
$ErrorActionPreference='Stop'
foreach ($case in @('transactions','processes','catalogue','shared','transaction-travel','restock','keys','preview','water-seed','water-load','transaction-seed','transaction-load')) {
    $extra=@{}
    if($case -eq 'shared') {$extra.Engine=Join-Path $PSScriptRoot '..\..\build\issue120\engine\gzdoom.exe'}
    if($case -eq 'water-load') {$extra.LoadGame='ca471i-water.zds'}
    if($case -eq 'transaction-load') {$extra.LoadGame='ca471i-seeded.zds'}
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Label "$Prefix-$case" -Runtime $Runtime -Checks -Addon integration-checks.pk3 -Script $case -TimeoutSeconds 45 @extra
}
