param([string]$Directory='issue247-confirmed', [string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA247-01: F prepares/cancels Formation Breaker. Double-tap forward within 0.4 seconds.'
Write-Host 'F6 resets this isolated Mercenary; F7 enables a wall-contact scenario. C toggles third-person view.'
Write-Host 'Check upright running from crouch, locked movement direction, the fading trail and normal speed on completion.'
Write-Host 'The fixture pins base statistics/resources; it does not load campaign saves.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5416/run_native.ps1 -Directory $Directory -Label $Label -Script manual.cfg -Language es -Interactive
