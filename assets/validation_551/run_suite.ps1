param([string]$Current='issue310-final03',[string]$Baseline='issue310-old-controls03',
    [string]$DeathCurrent='issue310-death01',[string]$DeathBaseline='issue310-old-death01',
    [string]$CastCurrent='issue310-cast02',[string]$CastBaseline='issue310-old-cast02',
    [switch]$ContinueAfterDeathControl,[switch]$ContinueAtCast)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$runner=Join-Path $root 'assets/validation_550/run_native.ps1'
if(!$ContinueAfterDeathControl -and !$ContinueAtCast) {
    & $runner -Directory $Current -Label paired-03 -Script paired.cfg
    & $runner -Directory $Baseline -Label paired-03 -Script paired.cfg
    & $runner -Directory $Current -Label two-pawns-01 -Script two-pawns.cfg -Engine (Join-Path $root 'build/issue310-engine/gzdoom.exe')
    & $runner -Directory $Current -Label auto-01 -Script auto.cfg
}
foreach($kind in @(0,1)) {
    foreach($stop in @('stun','death')) {
        if($ContinueAtCast -and $kind -eq 0){continue}
        if($ContinueAfterDeathControl -and $kind -eq 0 -and $stop -eq 'stun'){continue}
        if($kind -eq 1 -and $stop -eq 'stun') {
            & $runner -Directory $CastCurrent -Label switch-cast-current -Script switch-cast.cfg
            & $runner -Directory $CastBaseline -Label switch-cast-baseline -Script switch-cast.cfg
            continue
        }
        $currentDirectory=if($stop -eq 'death'){$DeathCurrent}else{$Current}
        $baselineDirectory=if($stop -eq 'death'){$DeathBaseline}else{$Baseline}
        & $runner -Directory $currentDirectory -Label "$stop-$kind-current" -Script "$stop-$kind.cfg"
        & $runner -Directory $baselineDirectory -Label "$stop-$kind-baseline" -Script "$stop-$kind.cfg"
    }
}
foreach($kind in @(0,1,2)) {
    foreach($action in @('save','load','hub','switch')) {
        $parameters=@{Directory=$Current;Label="$action-$kind-current";Script="$action-$kind.cfg"}
        if($action -eq 'load'){$parameters.LoadGame="action-$kind.zds"}
        & $runner @parameters
    }
    $legacy=Join-Path $root "build/issue309-persist04/action-$kind.zds"
    if($kind -eq 0){$legacy=Join-Path $root 'build/issue309-persist03/action-0.zds'}
    $target=Join-Path $root "build/$Current/legacy-action-$kind.zds"
    if(Test-Path -LiteralPath $target){throw "Preserve existing save: $target"}
    Copy-Item -LiteralPath $legacy -Destination $target
    & $runner -Directory $Current -Label "load-$kind-legacy" -Script "load-$kind.cfg" -LoadGame "legacy-action-$kind.zds"
}
& $runner -Directory $Current -Label held-load-current -Script held-load.cfg
& $runner -Directory $Current -Label boundaries-current -Script boundaries.cfg
