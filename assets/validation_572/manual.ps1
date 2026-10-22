param([string]$Label = ('author-' + (Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference = 'Stop'
$Host.UI.RawUI.WindowTitle = 'Caelum Argenteum - Prueba #405'
Clear-Host
Write-Host 'PRUEBA #405 - PLANTAS, COLMENAS Y MODELOS 3D' -ForegroundColor Cyan
Write-Host ''
Write-Host 'No necesitas escribir comandos en esta terminal: es una guia.'
Write-Host 'Las teclas siguientes se pulsan DENTRO DEL JUEGO.'
Write-Host ''
Write-Host 'F1: vuelve a la sala/galeria nueva. Camina para ver los modelos en 3D.'
Write-Host 'F2: colmena. Mira hacia ella y pulsa E: salen 50 g de miel.'
Write-Host 'F3: tienda de provisiones; revisa yerba, irupe y cana.'
Write-Host 'F4: marcela y espada. Clic izquierdo para cortar.'
Write-Host 'F5: fuentes reales fuera de la puerta oeste de MAP03.'
Write-Host 'F6: jardin de MAP01; esas plantas y colmena solo decoran.'
Write-Host 'F2-F4 se usan en la sala; despues de F5/F6 vuelve con F1.'
Write-Host ''
Write-Host 'WASD: moverte. Raton: mirar. E: interactuar. Tab: Diario/inventario.'
Write-Host 'Acercate a los materiales caidos para recogerlos.'
Write-Host 'Si ves la consola, pulsa Esc para volver al juego.'
Write-Host 'Al terminar, cuentame que paso y cierra el juego para continuar las pruebas.'
Write-Host ''
& (Join-Path $PSScriptRoot 'run_native.ps1') -Label $Label -Checks -Script interactive -Interactive
