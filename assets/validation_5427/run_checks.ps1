param([ValidatePattern('^[A-Za-z0-9_-]+$')][string]$Directory='issue307-08')
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot '..\validation_5425\run_native.ps1'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work=Join-Path $root "build\$Directory"
foreach($case in @('walking','contracts','seed')) {
    & $runner -Directory $Directory -Label "$case-01" -Fixture escort.pk3 -Script "$case.cfg" -Map MAP99 -Marker CA307
}
& $runner -Directory $Directory -Label load-01 -Fixture escort.pk3 -Script load.cfg -LoadGame escort.zds -Marker CA307
& $runner -Directory $Directory -Label repeat-01 -Fixture escort.pk3 -Script repeat.cfg -LoadGame repeated.zds -Marker CA307
& $runner -Directory $Directory -Label travel-01 -Fixture escort.pk3 -Script travel.cfg -LoadGame escort.zds -Marker CA307
$legacy="$Directory-legacy"
& $runner -Directory $legacy -Label baseline-01 -Fixture escort.pk3 -Script baseline.cfg -Map MAP99 -Marker CA307
& $runner -Directory $legacy -Label seed-01 -Fixture escort.pk3 -Script seed.cfg -Map MAP99 -Marker CA307
$copy=Join-Path $work 'legacy-escort.zds'
if(Test-Path -LiteralPath $copy){throw 'Preserve migration saves; use a fresh directory.'}
Copy-Item -LiteralPath (Join-Path $root "build\$legacy\escort.zds") -Destination $copy
& $runner -Directory $Directory -Label migration-01 -Fixture escort.pk3 -Script migration.cfg -LoadGame legacy-escort.zds -Marker CA307
& $runner -Directory $Directory -Label migration-repeat-01 -Fixture escort.pk3 -Script repeat.cfg -LoadGame migrated.zds -Marker CA307
& $runner -Directory $Directory -Label migration-hub-01 -Fixture escort.pk3 -Script travel.cfg -LoadGame legacy-escort.zds -Marker CA307
& $runner -Directory $Directory -Label motion-01 -Fixture escort.pk3 -Script motion.cfg -Map MAP99 -Marker CA307
