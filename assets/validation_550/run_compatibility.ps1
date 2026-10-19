param([string]$Current='issue309-persist04',[string]$Legacy='issue309-legacy01')
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
foreach ($kind in @(0,1,2)) {
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Directory $Legacy -Label "legacy-save-$kind" -Script "save-$kind.cfg"
    $target=Join-Path $root "build/$Current/legacy-action-$kind.zds"
    if (Test-Path -LiteralPath $target) {throw 'Preserve old compatibility saves; choose fresh directories.'}
    Copy-Item -LiteralPath (Join-Path $root "build/$Legacy/action-$kind.zds") -Destination $target
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Directory $Current -Label "legacy-load-$kind" -Script "load-$kind.cfg" -LoadGame "legacy-action-$kind.zds"
}
& (Join-Path $PSScriptRoot 'run_native.ps1') -Directory $Current -Label 'normal-package-gauntlet' -Script 'gauntlet.cfg' -Runtime '../caelum_argenteum_dev.pk3'
