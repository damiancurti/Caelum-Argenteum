param([string]$Label = ('author-' + (Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference = 'Stop'
$Host.UI.RawUI.WindowTitle = 'Caelum Argenteum - Prueba #470'
Clear-Host
Write-Host 'PRUEBA #470 - ESTACION 3D DE ALQUIMIA' -ForegroundColor Cyan
Write-Host ''
Write-Host 'No escribas comandos en esta terminal. Usa estas teclas DENTRO DEL JUEGO.'
Write-Host '1. Empiezas frente a Alquimia, en el taller de Ronnie (MAP01).'
Write-Host '2. Observa la mesa, el barril y el alambique desde varios lados con WASD/raton.'
Write-Host '3. Mira la estacion y pulsa E: abre el catalogo compartido del Banco. Q lo cierra.'
Write-Host '4. Comprueba que puedes rodearla y acceder a las otras estaciones y a la puerta.'
Write-Host '5. F2 abre MAP03 frente a su Alquimia. Repite las comprobaciones.'
Write-Host '6. F3 guarda; F4 carga. Debe seguir habiendo una sola estacion en el mismo lugar.'
Write-Host 'F1 vuelve a MAP01. F1/F2 reinician esos mapas solo en esta prueba.'
Write-Host 'Esta escena habilita las recetas existentes solo para mostrar el catalogo.'
Write-Host 'Las nuevas recetas se agregan en los issues siguientes; esta entrega prueba la estacion.'
Write-Host ''
Write-Host 'Si aparece la consola, pulsa Esc. Cierra el juego al terminar y comunica el resultado.'
& (Join-Path $PSScriptRoot 'run_native.ps1') -Label $Label -Checks -StartMap MAP01 -Script interactive -Interactive
