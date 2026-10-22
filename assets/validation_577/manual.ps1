param([string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')), [switch]$InstructionsOnly)
$ErrorActionPreference='Stop'
$Host.UI.RawUI.WindowTitle='Caelum Argenteum - Panel #481'
Clear-Host
Write-Host 'PRUEBA #481 - PANEL SUPERIOR CENTRADO' -ForegroundColor Cyan
Write-Host 'Usa estas teclas DENTRO DEL JUEGO. La terminal queda abierta.'
Write-Host 'F1: siguiente objetivo (enemigo, cofre, puerta, silla, transicion, Alquimia, cama).'
Write-Host 'F2: alterna Perspicacia entre 2 y 100.'
Write-Host 'Con Perspicacia 2: Fuerza 1 visible; Dureza 2 y Constitucion 3 ocultas.'
Write-Host 'Vida, Anima, Aire y Adrenalina se muestran siempre.'
Write-Host 'WASD y raton: movimiento libre. E: Usar. Cambia la tecla en controles para verificar la leyenda.'
Write-Host 'Mira a otro lado: el panel debe cambiar o desaparecer; las paredes deben ocultar lo que hay detras.'
Write-Host 'Abrir un menu/cofre debe ocultar el panel mientras interactuas.'
Write-Host 'Tambien podes iniciar MAP01 o MAP03 para revisar el HUD durante una partida normal.'
Write-Host 'Al terminar, informa si CA481-01 pasa o indica el objetivo/accion a corregir.'
if (!$InstructionsOnly) {
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Label $Label -Checks -Script interactive -Interactive
}
