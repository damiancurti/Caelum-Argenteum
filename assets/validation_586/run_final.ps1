$ErrorActionPreference='Stop'
$run=Join-Path $PSScriptRoot 'run_native.ps1'
& $run -Label final-load-01 -Script load -LoadGame ca411-property.zds -Checks
& $run -Label final-hub-01 -Script hub -LoadGame ca411-property.zds -Checks
& $run -Label final-house69-01 -Script house -StartMap CAH069 -Checks
& $run -Label final-house70-01 -Script house -StartMap CAH070 -Checks
& $run -Label final-access-01 -Script access -StartMap CAH069 -Checks
& $run -Label final-routes-01 -Script routes -Checks
& $run -Label final-legacy-load-01 -Script legacy-load -LoadGame ca411-original.zds -Checks -Addon bridge/legacy-checks.pk3
& $run -Label final-legacy-hub-01 -Script legacy-hub -LoadGame ca411-migrated.zds -Checks -Addon bridge/legacy-checks.pk3
& $run -Label final-legacy-return-01 -Script legacy-return -LoadGame ca411-relocated.zds -Checks -Addon bridge/legacy-checks.pk3
& $run -Label final-cross-01 -Script cross -StartMap CAH069 -Checks
& $run -Label final-preview-es-01 -Script preview -StartMap CAH069 -Language es -Checks
