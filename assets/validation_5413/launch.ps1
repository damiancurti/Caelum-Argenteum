param([string]$Directory='issue246-author', [string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA246-01: Arcane Sun isolated playtest. F cast/cancel; F6 free-flight reset; F7 wall reset.'
Write-Host 'Look for the three-second preparation, large orb, periodic guided fire and terminal burst.'
Write-Host 'The ally must remain unharmed; the enemy can burn. F7 tests a wall instead of expiration.'
Write-Host 'Close the game and report CA246-01, including any partial or failed step.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5413/run_native.ps1 -Directory $Directory -Label $Label -Fixture sun.pk3 -Script manual.cfg -Map MAP99 -Language es -Interactive
