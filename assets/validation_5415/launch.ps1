param([string]$Directory='issue260-author-ready', [string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA260-01 covers ordinary acceleration only. The double-tap impulse is not implemented.'
Write-Host 'F6/F7/F8 select 50/100/200 kg. Hold movement to see 1.5/3/6-second ramps; release to stop.'
Write-Host 'Try walking, running and lateral movement. This isolated fixture does not load campaign saves.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5415/run_native.ps1 -Directory $Directory -Label $Label -Script manual.cfg -Language es -Interactive
