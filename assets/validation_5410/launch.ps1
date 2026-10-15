param([string]$Directory='issue243-final-v2', [string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '..\..')
Write-Host 'CA243-01: Grito de guerra - escenario aislado'
Write-Host 'F: lanzar o cancelar. Preparacion 3 s, 1000 Anima, efecto 10 s, reutilizacion 60 s.'
Write-Host 'F6: reiniciar. F7: intimidarte durante 10 s. F8: guanteletes/baston. F9: siguiente criatura.'
Write-Host 'Con F7 no debes poder atacar, pero puedes moverte y bloquear con B y los guanteletes.'
Write-Host 'Las criaturas intimidadas siguen moviendose; sus ataques se reanudan al terminar.'
Write-Host 'Solo en este ensayo: invulnerabilidad, enemigo inmortal y recursos altos para su IA.'
Write-Host 'Cierra el juego al terminar y comunica el resultado de CA243-01.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5410/run_native.ps1 -Directory $Directory -Label $Label -Fixture cry.pk3 -Script manual.cfg -Map MAP99 -Language es -Interactive
