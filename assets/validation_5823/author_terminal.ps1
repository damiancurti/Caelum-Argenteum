param([string]$Runtime='final23')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $repo
Write-Host '#502 / CA502-LIMBO-HISTORY-01'
Write-Host 'An existing bedroom sink starts clean in the mansion. The private test leaves for 30 world minutes and returns.'
Write-Host 'Check the two CA502H MANUAL readings: zero before departure, ambient concentration after return.'
Write-Host 'The final console remains open. Close it to inspect the real sink; ordinary controls are loaded.'
Write-Host 'This test does not establish exterior weather history, household cleaning or body exposure.'
Read-Host 'Press Enter to launch'
$label='history-author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
& (Join-Path $PSScriptRoot 'run_native.ps1') -Label $label -Runtime $Runtime -Script history-author -Checks -Addon history-checks.pk3 -Interactive -Language es
Read-Host 'Keep this terminal open while inspecting the game; press Enter when done'
