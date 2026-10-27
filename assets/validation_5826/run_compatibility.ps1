param([string]$Runtime='final26c',[string]$Prefix='reading-final')
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot 'run_native.ps1'
& $runner -Runtime previous25 -Label ($Prefix+'-oldseed') -Script oldseed -Checks -Addon legacy.pk3
& $runner -Runtime $Runtime -Label ($Prefix+'-migration') -Script migration -Checks -LoadGame reading-legacy.zds
& $runner -Runtime previous25 -Label ($Prefix+'-rollback') -Script rollback -Checks -Addon legacy.pk3 -LoadGame reading-legacy.zds
& $runner -Runtime $Runtime -Label ($Prefix+'-label-smoke') -Script smoke
python (Join-Path $PSScriptRoot 'performance.py') previous25 ($Prefix+'-perf-base')
if($LASTEXITCODE -ne 0){throw 'Baseline measurement failed'}
python (Join-Path $PSScriptRoot 'performance.py') $Runtime ($Prefix+'-perf-current')
if($LASTEXITCODE -ne 0){throw 'Current measurement failed'}
