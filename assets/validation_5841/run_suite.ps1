param([string]$LabelPrefix='releaseb',[string]$Runtime='final41b')
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot 'run_native.ps1'
function Invoke-HouseCheck([string]$Case,[string]$Save='', [string]$Addon='checks.pk3',[string]$Map='MAP01') {
    & $runner -Label "$LabelPrefix-$Case" -Runtime $Runtime -Script $Case -LoadGame $Save -Addon $Addon -StartMap $Map -Checks -TimeoutSeconds 90
}
Invoke-HouseCheck 'seed' '' 'checks.pk3' 'MAP03'
Invoke-HouseCheck 'load' 'house-current.zds'
Invoke-HouseCheck 'back' 'house-current.zds'
Invoke-HouseCheck 'samehub' 'house-current.zds'
Invoke-HouseCheck 'perf' 'house-current.zds'
Invoke-HouseCheck 'migration' 'house-prior40.zds' 'legacy-checks.pk3'
Invoke-HouseCheck 'domestic-core' '' 'domestic-checks.pk3' 'MAP03'
Invoke-HouseCheck 'domestic-load' 'domestic-current.zds' 'domestic-checks.pk3'
Invoke-HouseCheck 'domestic-hub' 'domestic-current.zds' 'domestic-checks.pk3'
Invoke-HouseCheck 'domestic-shortages' 'domestic-current.zds' 'domestic-checks.pk3'
Invoke-HouseCheck 'domestic-clock' 'domestic-current.zds' 'domestic-checks.pk3'
Invoke-HouseCheck 'domestic-skipped' 'domestic-current.zds' 'domestic-checks.pk3'
