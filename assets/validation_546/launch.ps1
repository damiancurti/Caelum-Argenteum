param(
    [string]$Directory = 'issue242-final',
    [string]$Label = ('author-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA242-01: Respiracion sobrenatural - perfil Caelith aislado'
Write-Host 'F activa/apaga la racial; el icono izquierdo muestra su estado.'
Write-Host 'Compara correr, saltar, atacar y bloquear con la racial apagada/encendida.'
Write-Host 'Shift: correr. Espacio: saltar. B: activar/desactivar bloqueo. Clic: atacar.'
Write-Host 'Encendida consume Anima; apagada consume Aire. Quedarte quieto en tierra no cobra.'
Write-Host 'F7: agua. Con F activada, respirar consume Anima y conserva Aire.'
Write-Host 'F8: deja muy poca Anima. La racial se apaga y vuelve a gastar Aire.'
Write-Host 'F9: vacia Aire para comprobar que la racial pagada evita ahogarse.'
Write-Host 'F10: volver a tierra. F6: reiniciar recursos, salud y racial apagada.'
Write-Host 'La regeneracion esta desactivada para que el gasto sea visible. No hay invulnerabilidad.'
Write-Host 'Cierra el juego al terminar; esta terminal permanece abierta.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_546/run_native.ps1 -Directory $Directory -Label $Label -Fixture breathing.pk3 -Script manual.cfg -Map MAP99 -Language es -Interactive
