param([string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')), [switch]$InstructionsOnly)
$ErrorActionPreference='Stop'
$Host.UI.RawUI.WindowTitle='Caelum Argenteum - Arte #471'
Clear-Host
Write-Host 'PRUEBA VISUAL #471 - INGREDIENTES DE ALQUIMIA' -ForegroundColor Cyan
Write-Host ''
Write-Host 'Usa estas teclas DENTRO DEL JUEGO. La terminal queda abierta.'
Write-Host 'F1: ingrediente siguiente. F3: anterior. Hay 11 modelos e iconos.'
Write-Host 'F2: cambia el punto de vista; recorre los cuatro lados de cada modelo.'
Write-Host 'F4: abre el inventario real para revisar el nuevo icono del yodo. Q: cerrar.'
Write-Host 'WASD y raton: movimiento libre. F1/F3 vuelven a encuadrar.'
Write-Host ''
Write-Host 'Revisa siluetas, texturas, base apoyada y diferencias entre materiales.'
Write-Host 'El modelo de yodo es el ya aceptado. Los otros recursos son arte preparado;'
Write-Host 'todavia faltan datos aprobados para sus recetas, precios y existencias.'
Write-Host 'No se agregaron yacimientos naturales en Barracas.'
Write-Host ''
Write-Host 'Al terminar, informa si CA471-ART-01 pasa o indica objeto y vista a corregir.'
if (!$InstructionsOnly) {
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Label $Label -Checks -Script interactive -Interactive
}
