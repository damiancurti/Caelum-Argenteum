$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $taskRoot
$Host.UI.RawUI.WindowTitle='Caelum Argenteum 5.3.6 - Prueba #233'
function Probar233 {
    $stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File assets/validation_536/run_native.ps1 -Label "author-$stamp" -Fixture probe -AdditionalFixture legacy -Script interactive.cfg -Map MAP04 -Language esp -Interactive
}
Write-Host 'Prueba #233 / 5.3.6 - notas manuales' -ForegroundColor Cyan
Write-Host 'M abre/cierra el mapa. Desactiva Seguir (F) para desplazarlo.'
Write-Host 'Con el mapa abierto: Esc > Notas del mapa > Nueva en el centro.'
Write-Host 'Escribir texto abre el editor nativo. Enter termina el texto; Esc lo cancela.'
Write-Host 'Elige categoria pulsando su boton. Guardar confirma la nota.'
Write-Host 'La lista admite raton; arriba/abajo eligen nota, izq./der. accion, Enter activa.'
Write-Host 'Prueba editar/cancelar, borrar/cancelar, guardar/cargar y texto con acentos.'
Write-Host 'Las notas no descubren servicios; las marcas numeradas siguen disponibles.'
Write-Host 'Puedes asignar ca_map_notes en Opciones > Controles > Automapa.'
Write-Host 'F10 cierra el motor; la terminal queda abierta. Probar233 reinicia el ensayo.'
Probar233
