param([string]$Prefix = 'repro163')
$ErrorActionPreference = 'Stop'
$runner = Join-Path $PSScriptRoot 'run_native.ps1'
python (Join-Path $PSScriptRoot 'prepare.py')
if ($LASTEXITCODE -ne 0) { throw 'Package preparation failed.' }
& $runner -Label "$Prefix-legacy-create" -Fixture legacy -Script legacy-create.cfg -Baseline
foreach ($fixture in @('checks','crafting','npcs','inputs')) {
    & $runner -Label "$Prefix-$fixture" -Fixture $fixture -Script "$fixture.cfg"
}
& $runner -Label "$Prefix-prepared" -Fixture inputs -Script prepared-reload.cfg -LoadGame ca163-prepared.zds
& $runner -Label "$Prefix-attached" -Fixture inputs -Script attached-reload.cfg -LoadGame ca163-attached.zds
& $runner -Label "$Prefix-escape" -Fixture escape -Script escape.cfg
& $runner -Label "$Prefix-cut-reload" -Fixture escape -Script escape-reload.cfg -LoadGame ca163-cutting.zds
& $runner -Label "$Prefix-travel" -Fixture travel -Script travel.cfg
& $runner -Label "$Prefix-regression" -Fixture regression -Script regression.cfg
& $runner -Label "$Prefix-legacy-load" -Fixture legacy -Script legacy-reload.cfg -LoadGame ca163-legacy.zds
& $runner -Label "$Prefix-legacy-again" -Fixture legacy -Script legacy-again.cfg -LoadGame ca163-migrated.zds
& $runner -Label "$Prefix-visuals" -Fixture inputs -Script visuals.cfg
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$logs = Get-ChildItem -LiteralPath (Join-Path $root 'build\issue163') -Filter "$Prefix-*.txt"
$failures = $logs | Select-String -Pattern '^CA163 FAIL|Script error|VM execution aborted|Access violation'
if ($failures) { $failures | Write-Output; throw 'Native assertions failed; retain and inspect the logs.' }
$passes = @($logs | Select-String -Pattern '^CA163 PASS').Count
Write-Output "Native suite completed: $passes passing assertions. Inspect the native screenshots separately."
