param([string]$Directory='issue245-author', [string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA245-01: Miracle isolated playtest. F cast/cancel; F6 reset.'
Write-Host 'F7 moves the left ally inside/outside; F8 moves it behind the wall.'
Write-Host 'The right enemy never heals. Base pulse: +30 Health, +3 Lucidity, +300 Anima, +30 Air.'
Write-Host 'First pulse after one second; ten pulses. Player Lucidity also recovers naturally.'
Write-Host 'Close the game and report CA245-01, including any partial or failed step.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5412/run_native.ps1 -Directory $Directory -Label $Label -Fixture miracle.pk3 -Script manual.cfg -Map MAP99 -Language es -Interactive
