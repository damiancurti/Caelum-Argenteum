param([string]$Runtime='final28',[string]$Prefix='weather-final')
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot 'run_native.ps1'
& $runner -Runtime $Runtime -Label ($Prefix+'-core') -Script core -Checks
& $runner -Runtime $Runtime -Label ($Prefix+'-seed') -Script seed -Checks
& $runner -Runtime $Runtime -Label ($Prefix+'-resume') -Script resume -Checks -LoadGame weather-current28.zds
& $runner -Runtime $Runtime -Label ($Prefix+'-hub') -Script hub -Checks
& $runner -Runtime $Runtime -Label ($Prefix+'-perf') -Script perf -Checks
