param([string]$Directory='issue240-final', [string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA240-01: Socializacion humana - escenario aislado Ronnie/Caella'
Write-Host 'F: apagar la racial durante el dialogo. La opcion visible conserva el x2.'
Write-Host 'Arriba se muestran estado, Anima y Labia. Activa consume 10 Anima/s.'
Write-Host 'F6: reiniciar Ronnie. F7: reiniciar Caella. F8: casi sin Anima.'
Write-Host 'Si una tecla de reinicio no responde dentro del dialogo, pulsa Escape primero.'
Write-Host 'Ronnie: apaga con F y elige el plan (primera opcion); debe aceptarlo.'
Write-Host 'Caella: abre la primera opcion hasta ver 100%, apaga con F o agota con F8 y confirma.'
Write-Host 'Al cerrar la charla se pierde la bonificacion retenida. No se repiten resultados.'
Write-Host 'El escenario fija Elocuencia 4, Carisma 0 y regeneracion de Anima 0.'
Write-Host 'Cierra el juego al terminar; esta terminal permanece abierta.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_548/run_native.ps1 -Directory $Directory -Label $Label -Fixture socialization.pk3 -Script manual.cfg -Map MAP01 -Language es -Interactive
