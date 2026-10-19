param([string]$Directory='issue312-preview04',[string]$Label='author-preview01')
$ErrorActionPreference='Stop'
$Host.UI.RawUI.WindowTitle='Caelum Argenteum - Prueba #312 - Presion continua'
Write-Host '#312: PRESION CONTINUA; TU PERSONAJE ESTA PROTEGIDO.'
Write-Host 'F6 baja un techo sobre el cuerpo que tenes delante.'
Write-Host 'F7 cambia a dos cuerpos apilados: observa el contador de dano por peso.'
Write-Host 'F8 retira el peso. Tras cobrar el ultimo tramo, ese contador debe detenerse.'
Write-Host 'Se muestra dano acumulado porque la recuperacion normal puede ocultarlo en la vida.'
Write-Host 'Guarda/carga con el peso colocado; debe continuar normalmente.'
Write-Host 'F10 reinicia toda la sala. Los pesos extremos pertenecen solo a esta prueba.'
Write-Host 'Al terminar cierra GZDoom; esta terminal queda abierta.'
& (Join-Path $PSScriptRoot '..\validation_552\run_native.ps1') -Directory $Directory -Label $Label -Fixture preview.pk3 -Script preview.cfg -Map THAZARD -Interactive -Language es
Write-Host 'Prueba cerrada. La terminal conserva las instrucciones.'
