param([string]$Prefix='review53', [string]$Runtime='review53')
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot 'run_native.ps1'
& $runner -Label "$Prefix-core" -Runtime $Runtime -Checks -Script core
& $runner -Label "$Prefix-reload" -Runtime $Runtime -Checks -Script reload -LoadGame incident-repair.zds
& $runner -Label "$Prefix-bandits" -Runtime $Runtime -Checks -Script bandits
& $runner -Label "$Prefix-encounter" -Runtime $Runtime -Checks -Script encounter -StartMap CAR01
& $runner -Label "$Prefix-resume" -Runtime $Runtime -Checks -Script encounter-resume -LoadGame ambush-native.zds
& $runner -Label "$Prefix-clock" -Runtime $Runtime -Checks -Script native-clock -StartMap CAT619
& $runner -Label "$Prefix-camp" -Runtime $Runtime -Checks -Script camp -LoadGame ambush-native.zds -TimeoutSeconds 120
