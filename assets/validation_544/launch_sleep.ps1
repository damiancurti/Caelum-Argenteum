param(
    [string]$Directory = 'issue238-sleep-handoff',
    [string]$Label = ('author-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA238-02: posturas vivas de Sueno - rata, toro, Mandinga y Zupay'
Write-Host 'F7: siguiente criatura. F6: despertar/reiniciar Anima y reutilizacion.'
Write-Host 'F: preparar Sueno; esperar 3 segundos. Puedes caminar alrededor.'
Write-Host 'F8: un golpe de prueba a la criatura seleccionada (no depende de la mira).'
Write-Host 'Los dos primeros golpes la mantienen acostada; el tercero la despierta.'
Write-Host 'Repite con F6 y F sin golpear: debe despertar al terminar los 10 segundos.'
Write-Host 'El jugador es invulnerable. Esta prueba usa un perfil y mapa aislados.'
Write-Host 'Cierra el juego al terminar; esta terminal permanece abierta.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_544/run_native.ps1 -Directory $Directory -Label $Label -Fixture poses.pk3 -Script manual.cfg -Map MAP99 -Language es -Interactive
