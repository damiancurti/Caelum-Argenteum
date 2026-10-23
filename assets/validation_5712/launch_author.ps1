param([switch]$StartNow)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Host.UI.RawUI.WindowTitle='Caelum #487 - Fermentation Barrel'
Set-Location -LiteralPath $repo
Write-Host 'CA487-01: Fermentation Barrel. This terminal stays open.'
Write-Host 'The barrel is a large tun: 3402 L useful volume after the approved headspace.'
Write-Host 'Inspect it, walk around it, and walk into it to confirm solid collision.'
Write-Host 'E: open the shared catalogue. Q: close it.'
Write-Host 'F1: MAP01. F2: MAP03. F3: save. F4: load.'
Write-Host 'F5: disconnect Chemistry in this private test. F6: reconnect it.'
Write-Host 'Without Chemistry, using the barrel must fail; reconnection must restore access.'
Write-Host 'F7: English. F8: Spanish. Check the target label and capacity.'
Write-Host 'This test covers station infrastructure. New fermentation recipes remain issue #471.'
if(!$StartNow){Read-Host 'Press Enter after returning, when ready to start' | Out-Null}
$label='author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
& (Join-Path $PSScriptRoot 'run_native.ps1') -Label $label -Checks -Script interactive -StartMap MAP01 -Interactive
Write-Host 'The game is running. Keep this terminal for the test log and any errors.'
