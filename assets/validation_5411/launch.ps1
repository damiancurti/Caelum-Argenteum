param([string]$Directory='issue244-author', [string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA244-01: Instinto de supervivencia - escenario aislado'
Write-Host 'F: lanzar/cancelar. Preparacion 3 s, coste 1000 Anima, efecto 10 s, reutilizacion 60 s.'
Write-Host 'F6: reiniciar. F7: ganancia de Adrenalina. F8: baston/carabina. F9: golpe entrante.'
Write-Host 'Compara precision, critico, evasion y ganancia antes, durante y despues del efecto.'
Write-Host 'Durante: precision 300, critico/evasion x3 con limites y penalizaciones normales.'
Write-Host 'El golpe F9 usa evasion real; cada resultado es probabilistico.'
Write-Host 'Salud de ensayo al 50% para que la ganancia normal de Adrenalina no sea cero.'
Write-Host 'Cierra el juego y comunica el resultado de CA244-01.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5411/run_native.ps1 -Directory $Directory -Label $Label -Fixture instinct.pk3 -Script manual.cfg -Map MAP99 -Language es -Interactive
