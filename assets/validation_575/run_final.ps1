param([string]$Runtime='final', [string]$Prefix='final')
$ErrorActionPreference='Stop'
& "$PSScriptRoot/run_matrix.ps1" -Runtime $Runtime -Prefix $Prefix
& "$PSScriptRoot/run_persistence.ps1" -Runtime $Runtime -Prefix $Prefix
$runner=Join-Path $PSScriptRoot 'run_native.ps1'
& $runner -Label "$Prefix-campaign" -Runtime $Runtime -Script campaign -StartMap MAP03 -Checks -Visible
foreach ($case in @('gallery','author-smoke','author-save')) {
    & $runner -Label "$Prefix-$case" -Runtime $Runtime -Script $case -Checks -Visible
}
& $runner -Label "$Prefix-author-load" -Runtime $Runtime -Script author-load -LoadGame ca407-author-check.zds -Checks -Visible
& $runner -Label "$Prefix-live" -Runtime $Runtime -Script live -TimeoutSeconds 90 -Checks -Visible
& $runner -Label "$Prefix-performance" -Runtime $Runtime -Script performance -Checks -Visible
