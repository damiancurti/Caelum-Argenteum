param([string]$Directory='issue305-02')
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot '..\validation_5425\run_native.ps1'
foreach($case in @('formulas','environment','interruptions','input','roof')) {
    $map=if($case -eq 'roof'){'MAP97'}else{'MAP99'}
    & $runner -Directory $Directory -Label "$case-01" -Fixture seal.pk3 -Script "$case.cfg" -Map $map -Marker CA252
}
& $runner -Directory $Directory -Label seed-01 -Fixture registry.pk3 -Script seed.cfg -Map MAP99 -Marker CA252
& $runner -Directory $Directory -Label load-01 -Fixture registry.pk3 -Script registry-load.cfg -LoadGame seal.zds -Marker CA305
& $runner -Directory $Directory -Label travel-01 -Fixture registry.pk3 -Script registry-travel.cfg -LoadGame seal.zds -Marker CA305
$legacy="$Directory-legacy"
& $runner -Directory $legacy -Label seed-01 -Fixture registry.pk3 -Script seed.cfg -Map MAP99 -Marker CA252
$old=Join-Path $PSScriptRoot "..\..\build\$legacy\seal.zds"
$copy=Join-Path $PSScriptRoot "..\..\build\$Directory\legacy-seal.zds"
if(Test-Path -LiteralPath $copy){throw 'Preserve the existing migration save; use a fresh directory.'}
Copy-Item -LiteralPath $old -Destination $copy
& $runner -Directory $Directory -Label migration-01 -Fixture registry.pk3 -Script registry-load.cfg -LoadGame legacy-seal.zds -Marker CA305
& $runner -Directory $Directory -Label migration-hub-01 -Fixture registry.pk3 -Script registry-travel.cfg -LoadGame legacy-seal.zds -Marker CA305
