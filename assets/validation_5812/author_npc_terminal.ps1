param([switch]$Open)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Exposicion ambiental de NPC'
Write-Host 'CA502-NPC-01: soldado equipado y animal sin equipo.'
Write-Host 'La franja superior muestra contaminacion real y se actualiza sola.'
Write-Host 'F1 reinicia a cero. F2 SOLO informa: no reinicia ni aplica un golpe.'
Write-Host 'Observa varios segundos: cuerpo, armadura y armas aumentan hacia el ambiente.'
Write-Host 'No deben aumentar indefinidamente. F6 abre/cierra la consola.'
Write-Host 'Esta entrega no prueba limpieza de hogares ni contacto por roce.'
while($true){
 if($Open){$choice='1';$Open=$false}else{$choice=Read-Host '1 abrir; 2 pruebas automaticas; Q salir'}
 if($choice -eq 'q'){break}
 if($choice -notin @('1','2')){continue}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare_npc.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare NPC exposure fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot 'run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime npc-final02 -Label ('author-npc-'+$stamp) -Checks -Addon npc-checks.pk3 -Interactive -Script npc-manual -Language es
 }else{
  foreach($check in @('npc-core','npc-clock','npc-save','npc-load','npc-hub')){
   $extra=@{}
   if($check -in @('npc-load','npc-hub')){$extra.LoadGame='ca502n-current.zds'}
   & $runner -Runtime npc-final02 -Label ('author-'+$check+'-'+$stamp) -Checks -Addon npc-checks.pk3 -Script $check @extra
  }
 }
}
