param([string]$Directory='issue313-current08',[string]$Label='author-preview01')
$ErrorActionPreference='Stop'
$Host.UI.RawUI.WindowTitle='Caelum Argenteum - Prueba #313 - Peso de municiones'
Write-Host '#313: PESO DE MUNICIONES. TU PERSONAJE ESTA PROTEGIDO.'
Write-Host 'F6 elige carabina; F7 elige escopeta. Dispara contra el blanco de enfrente.'
Write-Host 'El contador superior debe perder 1 cartucho por disparo: 40g o 45g.'
Write-Host 'R recarga; recargar no debe volver a descontar cartuchos ni peso.'
Write-Host 'F8 mueve la municion del arma elegida entre inventario y Caja.'
Write-Host 'La cantidad y masa total superior se conservan; en el inventario cambia su ubicacion.'
Write-Host 'Guarda/carga para comprobar cantidades y cargador; F10 reinicia la sala.'
Write-Host 'No cambia el dano ni la penetracion. Al terminar cierra GZDoom.'
& (Join-Path $PSScriptRoot '..\validation_552\run_native.ps1') -Directory $Directory -Label $Label -Fixture qa.pk3 -Script preview.cfg -Interactive -Language es
Write-Host 'Prueba cerrada. La terminal conserva las instrucciones.'
