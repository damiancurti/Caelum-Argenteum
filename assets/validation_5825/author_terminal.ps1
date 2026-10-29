param([string]$Runtime='final25c')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $repo
Write-Host '#410 / CA410-WATER-FURNITURE-01'
Write-Host 'La fuente y la cisterna estan juntas en el jardin sur de la mansion.'
Write-Host 'Usar muestra la reserva. Apunta a una fuente, abre Inventario y selecciona botella u olla.'
Write-Host 'R recoge agua; G la deposita en la cisterna; V sigue descartandola. Los botones tambien admiten raton.'
Write-Host 'Fuente: 200 L potables, +1 L/minuto del mundo. Cisterna: 1000 L, empieza vacia y no se repone sola.'
Write-Host 'Shift+Usar permite banarse con agua potable y jabon. Esta partida privada incluye botella, olla,100 g de jabon y contaminacion30.'
Write-Host 'La cantimplora adicional contiene1 L con contaminacion biologica y sal para comprobar que la cisterna conserva su calidad.'
Write-Host 'Comprueba transferencias, cancelacion del bano, guardado/carga y apariencia. No hay macros F1/F2.'
Read-Host 'Pulsa Enter para iniciar la partida de prueba'
$label='water-author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
& (Join-Path $PSScriptRoot 'run_native.ps1') -Label $label -Runtime $Runtime -Script water-furniture-author -Checks -Addon water-furniture-checks.pk3 -Interactive -Language es
Read-Host 'La terminal permanece abierta. Pulsa Enter cuando termines'
