param([string]$Directory='issue311-final04',[string]$Label='author-preview01')
$ErrorActionPreference='Stop'
$Host.UI.RawUI.WindowTitle='Caelum Argenteum - Prueba #311'
Write-Host '#311 - CONTACTOS MULTIPLES'
Write-Host 'Hay tres cuerpos visibles frente a vos. Tu personaje esta protegido.'
Write-Host 'F6: los dos extremos chocan con el central; observa los contadores.'
Write-Host 'F7: separa los cuerpos y repite; cada golpe nuevo debe contar una vez.'
Write-Host 'F8: prueba una caida sobre una pila de cuerpos.'
Write-Host 'Quedarse juntos no debe repetir golpes. Prueba guardar/cargar.'
Write-Host 'F10 reinicia la sala. Al terminar cierra GZDoom; esta terminal queda abierta.'
& (Join-Path $PSScriptRoot 'run_native.ps1') -Directory $Directory -Label $Label -Fixture preview.pk3 -Script preview.cfg -Interactive -Language es
Write-Host 'Prueba cerrada. La terminal conserva estas instrucciones.'
