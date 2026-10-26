$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Contaminacion por golpes'
Write-Host 'CA502-COMBAT-01: contacto real de espada, mordida, escudo y esquiva.'
Write-Host 'F1 espada sucia; F3 objetivo sucio; F4 mordida; F5 escudo; F7 esquiva.'
Write-Host 'Despues pulsa F2: prepara valores controlados y ejecuta un golpe real.'
Write-Host 'Referencia 80kg: el receptor limpio pasa de0 a0,8. La fuente conserva80.'
Write-Host 'Con escudo, solo el escudo recibe0,8. Al esquivar no hay transferencia.'
Write-Host 'La franja superior conserva los datos del ultimo golpe; el ambiente sigue despues.'
Write-Host 'F6 abre/cierra la consola. Este laboratorio no prueba rutinas ni exposicion de NPC.'
while($true){
 $choice=Read-Host '1 abrir prueba manual; 2 comprobaciones automaticas; Q salir'
 if($choice -eq 'q'){break}
 if($choice -notin @('1','2')){continue}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare_combat.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare combat-contact fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot 'run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime combat-final01 -Label ('author-combat-'+$stamp) -Checks -Addon combat-checks.pk3 -Interactive -Script combat-manual -Language es
 }else{
  foreach($check in @('combat-core','combat-trace','combat-models','combat-save','combat-load','combat-hub')){
   $extra=@{}
   if($check -in @('combat-load','combat-hub')){$extra.LoadGame='ca502m-combat.zds'}
   & $runner -Runtime combat-final01 -Label ('author-'+$check+'-'+$stamp) -Checks -Addon combat-checks.pk3 -Script $check @extra
  }
 }
}
