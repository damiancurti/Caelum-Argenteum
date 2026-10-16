param(
    [string]$Directory = 'issue241-handoff',
    [string]$Label = ('author-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA241-01: Telequinesis - prueba aislada de Duende'
Write-Host 'Apunta al cuerpo y pulsa F para sujetarlo; mueve la mira. F otra vez lo suelta.'
Write-Host 'Mientras esta sujeto no puede atacar ni moverse voluntariamente; consume Anima.'
Write-Host 'F6: reiniciar Mandinga y recursos. F7: rata. F8: toro. F9: roca pesada.'
Write-Host 'Compara movimiento y consumo: mas masa requiere mas Anima y acelera menos.'
Write-Host 'F10: alternar fuerza de Int 25 (1700 N) / Int 100 (8000 N), sin personalidad.'
Write-Host 'La roca pesada no se eleva con fuerza insuficiente; aumenta la fuerza para elevarla.'
Write-Host 'F11: casi sin Anima. Debe soltarse y conservar la fraccion restante.'
Write-Host 'Comprueba el contacto con paredes/suelo y la caida al soltar en el aire.'
Write-Host 'Perfil de prueba: reserva de 10000 Anima, sin regeneracion, salud protegida.'
Write-Host 'Cierra el juego al terminar; esta terminal permanece abierta.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_547/run_native.ps1 -Directory $Directory -Label $Label -Fixture telekinesis.pk3 -Script manual.cfg -Map MAP99 -Language es -Interactive
