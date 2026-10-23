param([switch]$StartNow)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Host.UI.RawUI.WindowTitle='Caelum #486 - Chemistry station name'
Set-Location -LiteralPath $repo
Write-Host 'CA486-01: Chemistry / Quimica station names. This terminal stays open.'
Write-Host 'Aim at the station, press E to use it, and Q to close crafting.'
Write-Host 'F1: MAP01. F2: MAP03. F3: English. F4: Spanish.'
Write-Host 'Check the target name in both languages and ordinary crafting access.'
Write-Host 'This patch preserves the existing station appearance and behavior.'
Write-Host 'The Fermentation Barrel belongs to separate issue #487.'
if(!$StartNow){Read-Host 'Press Enter when ready to start' | Out-Null}
$label='author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
& (Join-Path $PSScriptRoot 'run_native.ps1') -Label $label -Checks -Script interactive -StartMap MAP01 -Interactive
Write-Host 'The game is running. Keep this terminal for the test log and any errors.'
