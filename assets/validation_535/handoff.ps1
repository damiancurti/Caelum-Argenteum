$ErrorActionPreference='Stop'
Set-Location 'C:\GZDooMProjects\CaelumArgenteum'
$Host.UI.RawUI.WindowTitle='Caelum Argenteum 5.3.5 - Prueba #232'
function Probar232 {
    param([string]$Modo='Servicios')
    $stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
    $map=if($Modo -eq 'Transporte'){'MAP06'}else{'MAP04'}
    $script=if($Modo -eq 'Transporte'){'interactive-transport.cfg'}else{'interactive.cfg'}
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File assets/validation_535/run_native.ps1 -Label "author-$stamp" -Fixture hooks -AdditionalFixture legacy -Script $script -Map $map -Language esp -Interactive
}
Write-Host 'Prueba #232 / 5.3.5 - descubrimiento por interaccion' -ForegroundColor Cyan
Write-Host 'Probar232             : cama, estacion, comerciante y salida de prueba'
Write-Host 'Probar232 Transporte  : carro existente de MAP06; ruta costera deshabilitada'
Write-Host 'Prueba corregida: MAP04 conserva los muebles; MAP03 los retira automaticamente.'
Write-Host 'F5 diagnostico | F6 cama | F7 estacion | F8 comerciante | F9 salida | F10 cerrar'
Write-Host 'Cierra M antes de cambiar el servicio. Se coloca delante de ti.'
Write-Host 'M antes de Usar: sin descubrimiento. Usa y cancela la oferta: aparece el icono.'
Write-Host 'Una interaccion bloqueada tambien debe registrarlo, sin desbloquearla.'
Write-Host 'Puedes guardar/cargar con el menu nativo; cada Probar232 crea otra partida aislada.'
Write-Host 'Los servicios de esta prueba se registran solo en el fixture; #234 los integra en los mapas.'
Write-Host 'La ventana queda abierta para repetir la prueba.'
Probar232
