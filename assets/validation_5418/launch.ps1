param([string]$Directory='issue249-final', [string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA249-01: aim at the floor, then F prepares/cancels Summoning; F6 resets.'
Write-Host 'F7 refills Anima and clears cooldown for another cast; F8 creates an ally and an enemy.'
Write-Host 'F9 wounds the summoned Zupay and changes map; F10 advances a one-hour journey.'
Write-Host 'The overlay reports Health, reserves and remaining lifetime. Campaign saves are not loaded.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5418/run_native.ps1 -Directory $Directory -Label $Label -Script manual.cfg -Language es -Interactive
