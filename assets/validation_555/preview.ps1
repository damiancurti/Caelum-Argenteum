param([string]$Directory='issue363-current05',[string]$Label='author-preview01')
$ErrorActionPreference='Stop'
Write-Host '#363 - UNARMED EQUIPPED-SEAL CHANNEL'
Write-Host 'X starts the channel; releasing keeps it active. Press X again to stop.'
Write-Host 'F6: fists. F7: sword. F8: wand. F9: empty Adrenaline. F10: refill for the fixture.'
Write-Host 'Holding X must create only one channel and spend Adrenaline. Empty resources must reject.'
Write-Host 'Also check save/load. Close GZDoom when finished and report the result.'
& (Join-Path $PSScriptRoot 'run_native.ps1') -Directory $Directory -Label $Label -Script manual.cfg -Interactive -Language es
Write-Host 'GZDoom closed. This terminal remains open. Author acceptance is still manual.'
