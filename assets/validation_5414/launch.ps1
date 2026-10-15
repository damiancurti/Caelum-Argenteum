param([string]$Directory='issue253-final-v2', [string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA253-01: original MAP01 assisted bull encounter. Move forward and let the bull damage you to 1 HP.'
Write-Host 'Eligible residents should keep moving/fighting. Their own downing and finite resources still apply.'
Write-Host 'F7 is an optional diagnostic finish for the bull, to inspect the existing victory/dialogue transition.'
Write-Host 'Close the game and report CA253-01. This isolated launcher does not load a campaign save.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5414/run_native.ps1 -Directory $Directory -Label $Label -Script manual.cfg -Map MAP01 -Language es -Interactive
