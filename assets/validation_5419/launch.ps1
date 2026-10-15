param([string]$Directory='issue250-release', [string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA250-01: F prepares/cancels Redemption. F6 resets the isolated scene.'
Write-Host 'Center: former enemy. Left: revived ally. Right: already-living ally.'
Write-Host 'F7 refills Anima/cooldown. F8 creates a corpse; pressing again kills it after revival.'
Write-Host 'F9 changes map with temporary allies; F10 advances a one-hour journey.'
Write-Host 'The overlay shows Health, Toughness factors and duration. Campaign saves are not loaded.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5419/run_native.ps1 -Directory $Directory -Label $Label -Script manual.cfg -Language es -Interactive
