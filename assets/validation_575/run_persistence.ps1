param([string]$Runtime='current', [string]$Prefix='final')
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot 'run_native.ps1'
& $runner -Label "$Prefix-upgrade" -Runtime $Runtime -Script upgrade -LoadGame ca407-legacy.zds -Addon upgrade/legacy-checks.pk3 -Checks -Visible
& $runner -Label "$Prefix-upgrade-load" -Runtime $Runtime -Script upgrade-load -LoadGame ca407-upgraded.zds -Addon upgrade/legacy-checks.pk3 -Checks -Visible
& $runner -Label "$Prefix-legacy-task-load" -Runtime $Runtime -Script legacy-task-load -LoadGame ca407-legacy-task.zds -Addon upgrade/legacy-checks.pk3 -Checks -Visible
& $runner -Label "$Prefix-save" -Runtime $Runtime -Script save -Checks -Visible
& $runner -Label "$Prefix-load" -Runtime $Runtime -Script load -LoadGame ca407-current.zds -Checks -Visible
& $runner -Label "$Prefix-travel" -Runtime $Runtime -Script travel -LoadGame ca407-current.zds -Checks -Visible
& $runner -Label "$Prefix-task-save" -Runtime $Runtime -Script task-save -Checks -Visible
& $runner -Label "$Prefix-task-load" -Runtime $Runtime -Script task-load -LoadGame ca407-task.zds -Checks -Visible
