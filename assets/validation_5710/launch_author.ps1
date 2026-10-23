param([switch]$StartNow)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Host.UI.RawUI.WindowTitle='Caelum #471 - Cartridge station test'
Set-Location -LiteralPath $repo
Write-Host 'Issue #471: cartridge assembly at Alchemy. This terminal stays open.'
Write-Host 'The private scene supplies both kits, learned recipes and maximum practice.'
Write-Host 'Use the crafting controls to make ten carbine/shotgun cartridges.'
Write-Host 'F2 switches Alchemy / Ranged Workshop: only Alchemy should allow new cartridges.'
Write-Host 'Cancellation, waiting and save/load use the normal game controls.'
if(!$StartNow){Read-Host 'Press Enter when you return and want to start' | Out-Null}
$label='author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
& (Join-Path $PSScriptRoot 'run_native.ps1') -Label $label -Checks -Script interactive -Interactive
Write-Host 'The game is running. Keep this terminal for the test log and any errors.'
