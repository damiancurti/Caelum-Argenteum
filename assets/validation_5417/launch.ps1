param([string]$Directory='issue248-delivery', [string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA248-01: F prepares/cancels Rally; F6 resets the isolated Cleric.'
Write-Host 'F7 moves the ally outside/inside range; F10 moves it behind the wall.'
Write-Host 'F8 receives a controlled hit; F9 deals one; F11 sets Adrenaline to 50%.'
Write-Host 'The overlay reports each pre-hit factor and actual Health loss. Campaign saves are not loaded.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5417/run_native.ps1 -Directory $Directory -Label $Label -Script manual.cfg -Language es -Interactive
