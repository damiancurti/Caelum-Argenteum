$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #411 - Carpa y terreno'
Write-Host 'CA411-TENT-01. Sala privada; no modifica tus partidas de campana.'
Write-Host 'Carpa ampliada: 4 m de ancho x 3 m de fondo, 1,8 m de alto; 18,8 kg.'
Write-Host '1: prueba manual. Si aparece un dialogo introductorio, cerralo con Escape.'
Write-Host 'F3 va a suelo pavimentado: activar la carpa desde el inventario debe rechazar el montaje.'
Write-Host 'F4 vuelve al jardin: activa la carpa para montar. Activarla otra vez cancela sin perderla.'
Write-Host 'F5 acelera el trabajo atendido y se detiene al terminar (10 minutos del juego).'
Write-Host 'Revisa el modelo, la entrada hacia tu posicion y el acceso agachado.'
Write-Host 'Usar sobre la carpa inicia desmontaje; F5 lo completa en 5 minutos del juego.'
Write-Host 'F2 muestra tarea/tiempo/carpa en consola. Prueba guardar/cargar montada y durante el montaje.'
Write-Host '2: comprobaciones nativas. No incluye fogata, cocina ni descanso nuevo para dos ocupantes.'
while($true){
 $choice=Read-Host '1 sala; 2 checks; Q deja la terminal abierta'
 if($choice -eq 'q'){break}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare private fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 if($choice -eq '1'){
  & (Join-Path $PSScriptRoot 'run_native.ps1') -Runtime wide-final -Label ('author-tent-'+$stamp) -Checks -Addon deploy.pk3 -Interactive -Script deploy-manual -Language es
 } elseif($choice -eq '2'){
  foreach($check in @('wide','core','land','climate','handoff')){
   & (Join-Path $PSScriptRoot 'run_native.ps1') -Runtime wide-final -Label ('author-tent-'+$check+'-'+$stamp) -Checks -Addon deploy.pk3 -Script ('deploy-'+$check)
  }
 }
}
