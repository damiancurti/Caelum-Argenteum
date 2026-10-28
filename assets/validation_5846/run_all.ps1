param([string]$Runtime='final46e',[string]$Prefix='delivery')
$ErrorActionPreference='Stop'
& "$PSScriptRoot/run_suite.ps1" -Runtime $Runtime -Prefix $Prefix
& "$PSScriptRoot/run_regressions.ps1" -Runtime $Runtime -Prefix "${Prefix}46"
