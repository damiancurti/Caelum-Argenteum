param([string]$Directory='issue260-impulse-final', [string]$Label=('author-impulse-'+(Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA260-02: double-tap any movement direction within 0.4 seconds, releasing between presses.'
Write-Host 'F6/F7/F8 select 50/100/200 kg. Test walking, running, crouching and a held diagonal.'
Write-Host 'The overlay counts successful impulses and their Air cost. F9 pins Air to zero; F7 resets.'
Write-Host 'Resources are restored by this isolated fixture. It does not load campaign saves.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5415/run_native.ps1 -Directory $Directory -Label $Label -Script impulse-manual.cfg -Language es -Interactive
