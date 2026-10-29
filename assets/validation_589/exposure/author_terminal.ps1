$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Exposicion ambiental'
Write-Host 'CA502-EXPOSURE-01. Sala privada; no modifica partidas de campana.'
Write-Host 'Mira Diario > Mundo: contaminacion ambiental junto a temperatura/humedad.'
Write-Host 'El HUD de supervivencia muestra la contaminacion del cuerpo, que aumenta gradualmente.'
Write-Host 'F1 reinicia el caso. F2 compara espera real/pronostico; F3 repite con ropa; F4 comprueba viaje.'
Write-Host 'F6 abre/cierra la consola del juego para leer PASS/FAIL. Cierra la introduccion con Escape.'
Write-Host 'Esta etapa cubre al jugador y su equipo llevado. NPC, contactos, agua y limpieza siguen pendientes.'
while($true){
 $choice=Read-Host '1 sala manual; 2 comparaciones automaticas; Q volver'
 if($choice -eq 'q'){break}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare exposure fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot '../run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime exposure-final2 -Label ('author-exposure-'+$stamp) -Checks -Addon exposure/checks.pk3 -Interactive -Script exposure/manual -Language es
 } elseif($choice -eq '2'){
  foreach($check in @('core','wait','wait_equipped','journey')){
   & $runner -Runtime exposure-final2 -Label ('author-exposure-'+$check+'-'+$stamp) -Checks -Addon exposure/checks.pk3 -Script ('exposure/'+$check)
  }
 }
}
