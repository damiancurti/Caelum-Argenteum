param([string]$Runtime='final27',[string]$Prefix='interior-final')
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot 'run_native.ps1'
& $runner -Runtime $Runtime -Label ($Prefix+'-core') -Script core -Checks
& $runner -Runtime $Runtime -Label ($Prefix+'-property') -Script property -StartMap CAH069 -Checks
& $runner -Runtime $Runtime -Label ($Prefix+'-seed') -Script seed -Checks
& $runner -Runtime $Runtime -Label ($Prefix+'-resume') -Script resume -Checks -LoadGame interior-progress.zds
& $runner -Runtime $Runtime -Label ($Prefix+'-hub') -Script hub -Checks
& $runner -Runtime $Runtime -Label ($Prefix+'-migration') -Script migration -Checks -LoadGame reading-progress.zds
& $runner -Runtime $Runtime -Label ($Prefix+'-view') -Script view -Language es -Checks
