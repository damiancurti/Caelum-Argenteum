param([string]$Runtime='final28',[string]$Prefix='weather-final')
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot 'run_native.ps1'
& $runner -Label ($Prefix+'-objects') -Runtime $Runtime -Script objects-core -Addon objects.pk3 -StartMap CAO502 -Tag CA502O -Checks
& $runner -Label ($Prefix+'-storage') -Runtime $Runtime -Script objects-storage -Addon objects.pk3 -StartMap CAO502 -Tag CA502O -Checks
& $runner -Label ($Prefix+'-limbo') -Runtime $Runtime -Script limbo-core -Addon limbo.pk3 -StartMap MAP01 -Tag CA502H -Checks
& $runner -Label ($Prefix+'-limbohub') -Runtime $Runtime -Script limbo-hub -Addon limbo.pk3 -StartMap MAP01 -Tag CA502H -Checks
