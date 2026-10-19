param([string]$Directory='issue309-preview01',[string]$Label='author-preview01')
$ErrorActionPreference='Stop'
Write-Host '#309 - PRUEBA DE ARMAS'
Write-Host 'F6: espada. F7: varita. F8: escopeta vacia con municion. F9: guanteletes.'
Write-Host 'Manten R ocho segundos: la carga debe completarse UNA vez y vencer.'
Write-Host 'Suelta R y pulsa de nuevo para iniciar otra. Dispara despues de cargar.'
Write-Host 'Con F8, manten disparo: debe recargar y disparar sin atascarse.'
Write-Host 'Avanza hacia los blancos para probar los golpes. F10 reinicia la sala.'
Write-Host 'Prueba guardar/cargar. Al terminar, cierra GZDoom y comunica el resultado.'
& (Join-Path $PSScriptRoot 'run_native.ps1') -Directory $Directory -Label $Label -Script manual.cfg -Interactive -Language es
Write-Host 'GZDoom cerrado. La terminal queda abierta; la aceptacion del autor sigue siendo manual.'
