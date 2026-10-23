param([string]$Label = ('author-' + (Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference = 'Stop'
$Host.UI.RawUI.WindowTitle = 'Caelum Argenteum - Prueba #406'
Clear-Host
Write-Host 'PRUEBA #406 - RECUPERACION DE RECURSOS' -ForegroundColor Cyan
Write-Host ''
Write-Host 'No escribas comandos aqui. Pulsa estas teclas DENTRO DEL JUEGO.'
Write-Host '1. Mira la colmena y pulsa E: extrae hasta 50 g por pulsacion.'
Write-Host '2. F3 muestra la reserva actual. Empieza con 500 g.'
Write-Host '3. F2 adelanta 100 dias SOLO en esta prueba: recupera 50 g, hasta 500.'
Write-Host '4. Repite F3: consultar no debe volver a sumar esos 50 g.'
Write-Host '5. F4 guarda. F5 carga: la reserva debe conservarse.'
Write-Host '6. Despues de F2, extrae otra vez con E. Pulsa F6 y luego F2:'
Write-Host '   retroceder y regresar esos 100 dias NO debe recuperar otra vez la miel.'
Write-Host 'F1 vuelve a mostrar instrucciones/estado sin reiniciar la reserva.'
Write-Host 'La recuperacion normal es lenta; pequenas fracciones entre consultas son normales.'
Write-Host ''
Write-Host 'WASD: moverte. Raton: mirar. E: recoger. Tab: Diario/inventario.'
Write-Host 'Si aparece la consola, pulsa Esc. Cierra el juego al terminar y comunica el resultado.'
& (Join-Path $PSScriptRoot 'run_native.ps1') -Label $Label -Checks -Script interactive -Interactive
