param([ValidatePattern('^issue339-[a-z0-9_-]+$')][string]$Directory='issue339-preview01')
$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Write-Host 'Prueba #339: corre hacia la pared y salta con Espacio; prueba al subir y al bajar.'
Write-Host 'F6 reinicia este escenario. El dano real sigue activo; golpes excesivos pueden matar.'
Write-Host 'M abre el mapa. L muestra u oculta toda la leyenda (#321).'
Write-Host 'Cierra GZDoom al terminar. Esta terminal queda abierta.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5422/run_native.ps1 `
    -Directory $Directory -Label author-preview -Script manual.cfg -Map MAPQA -Language es -Interactive
if($LASTEXITCODE -ne 0){throw 'Preview runner failed; inspect the native log.'}
