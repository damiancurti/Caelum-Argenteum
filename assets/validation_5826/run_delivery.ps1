param([string]$Runtime='final26c',[string]$Prefix='reading-delivery')
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot 'run_native.ps1'
& $runner -Runtime $Runtime -Label ($Prefix+'-core') -Script core -Checks
& $runner -Runtime $Runtime -Label ($Prefix+'-spanish') -Script core -Language es -Checks
& $runner -Runtime $Runtime -Label ($Prefix+'-view2') -Script view2 -Language es -Checks
