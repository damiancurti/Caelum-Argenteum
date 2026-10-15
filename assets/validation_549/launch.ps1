param([string]$Directory='issue239-manual-v3', [string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA239-01: Instinto del cazador - escenario aislado'
Write-Host 'F: activar/apagar. Sigilo 20% -> 60%; consume 10 Anima/s.'
Write-Host 'F6: girar al Mandinga. F7: baston/carabina. F8: agotar Anima. F9: reiniciar.'
Write-Host 'Dispara activo por detras y apaga durante el vuelo: debe ser critico.'
Write-Host 'Dispara inactivo y activa durante el vuelo: no debe ser critico.'
Write-Host 'Dispara activo y gira al blanco con F6 antes de impactar: no debe ser critico.'
Write-Host 'Comprueba arriba Critico, Activa al disparar e Impactos. Prueba ambas armas.'
Write-Host 'Solo en este ensayo: base 20%, tirada 50%, precision alta y vuelo lento sin gravedad.'
Write-Host 'F8 debe apagar el efecto; F9 restaura la escena y 10000 Anima.'
Write-Host 'Cierra el juego al terminar; esta terminal permanece abierta.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_549/run_native.ps1 -Directory $Directory -Label $Label -Fixture hunter.pk3 -Script manual.cfg -Map MAP99 -Language es -Interactive
