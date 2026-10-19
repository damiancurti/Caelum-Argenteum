param([string]$Directory='issue314-current07',[string]$Label='author-preview01')
$ErrorActionPreference='Stop'
Write-Host '#314 - HIELO Y LAVA / SALA DE PRUEBA'
Write-Host 'F6: hielo -40 C. F7: lava 1000 C. F8: suelo neutro. F9: agua sobre hielo.'
Write-Host 'F10: restablecer salud y exposicion para repetir la prueba.'
Write-Host 'Observe E y salud. Pruebe agacharse, saltar, salir del suelo y guardar/cargar.'
Write-Host 'La exposicion acumulada persiste al salir; cesa el intercambio con el suelo.'
Write-Host 'Cierre GZDoom al terminar y cuente el resultado. Esta terminal queda abierta.'
& (Join-Path $PSScriptRoot 'run_native.ps1') -Directory $Directory -Label $Label -Script manual.cfg -Interactive -Language es
Write-Host 'GZDoom cerrado. La aceptacion depende de su confirmacion.'
