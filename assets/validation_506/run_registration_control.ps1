param([switch]$CollectOnly)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build/issue128'
$label = 'register-before-a'
$failed = [bool]$CollectOnly
if (!$CollectOnly) {
    try { & (Join-Path $PSScriptRoot 'run_check.ps1') -Label $label -Package 'pruned-cannon.pk3' }
    catch { $failed = $true }
}
$record = Get-Content -LiteralPath (Join-Path $work "$label-run.json") -Raw | ConvertFrom-Json
$owned = Get-Process -Id $record.pid -ErrorAction SilentlyContinue
if ($owned -and !$owned.WaitForExit(5000)) { throw 'Negative-control engine has not exited.' }
$raw = Get-Content -LiteralPath (Join-Path $work "$label.txt") -Raw -Encoding utf8
$expected = 'CA128 FAIL tic=10 NOBLOCKMAP registration after census is observed in the same tic'
if (!$failed -or !$raw.Contains($expected) -or ([regex]::Matches($raw,'CA128 FAIL')).Count -ne 1 -or $raw -match 'Script error,|VM execution aborted') { throw 'Registration negative control did not isolate the expected defect.' }
$record | Add-Member -NotePropertyName expected_failure -NotePropertyValue $expected -Force
$record | Add-Member -NotePropertyName negative_control_verified -NotePropertyValue $true -Force
$record | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $work "$label-run.json") -Encoding utf8
foreach ($suffix in @('.txt','.ini','-run.json')) { Copy-Item -LiteralPath (Join-Path $work ($label+$suffix)) -Destination (Join-Path $PSScriptRoot ($label+$suffix)) }
Write-Output 'Verified the regression control fails only without same-tic NOBLOCKMAP registration.'
