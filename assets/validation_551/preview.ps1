param([string]$Directory='issue310-preview01',[string]$Label='author-preview01')
$ErrorActionPreference='Stop'
$Host.UI.RawUI.WindowTitle='Caelum Argenteum - Prueba #310'
Write-Host '#310 - COORDINACION DEL COMBATE'
Write-Host 'Esta prueba debe sentirse igual que la anterior: no cambia el balance.'
Write-Host 'F6 espada | F7 varita | F8 alabarda | F9 jabalina | F11 carabina.'
Write-Host 'Mouse izquierdo/derecho: ataques. Mouse central: barrido con alabarda.'
Write-Host 'R: carga/recarga. Prueba cargar, atacar y cambiar de arma durante la carga.'
Write-Host 'Acercate a los blancos. La jabalina usa Alt cerca o lejos del blanco.'
Write-Host 'Prueba guardar/cargar. F10 reinicia la sala. Al terminar, cierra GZDoom.'
& (Join-Path $PSScriptRoot '../validation_550/run_native.ps1') -Directory $Directory -Label $Label -Script manual.cfg -Interactive -Language es
Write-Host 'Prueba cerrada. La terminal queda abierta para consultar las instrucciones.'
