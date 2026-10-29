param([string]$LabelPrefix='release',[string]$Runtime='final42a')
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot 'run_native.ps1'
function Invoke-Case([string]$Case,[string]$Save='',[string]$Map='MAP01') {
    & $runner -Label "$LabelPrefix-$Case" -Runtime $Runtime -Script $Case -LoadGame $Save -StartMap $Map -Checks -TimeoutSeconds 90
}
Invoke-Case 'seed' '' 'MAP03'
Invoke-Case 'reload' 'furniture-back.zds'
Invoke-Case 'away-load' 'furniture-away.zds'
Invoke-Case 'samehub' 'furniture-back.zds'
Invoke-Case 'core' 'furniture-back.zds'
Invoke-Case 'clean' 'furniture-back.zds'
Invoke-Case 'clean-load' 'furniture-clean.zds'
Invoke-Case 'migration' 'furniture-prior41.zds'
& $runner -Label "$LabelPrefix-reg-core" -Runtime $Runtime -Script reg-core -StartMap MAP03 -Addon regression-checks.pk3 -Checks -TimeoutSeconds 90
foreach($case in @('shortages','skipped')) {
    & $runner -Label "$LabelPrefix-reg-$case" -Runtime $Runtime -Script "reg-$case" -LoadGame domestic-current.zds -Addon regression-checks.pk3 -Checks -TimeoutSeconds 90
}
