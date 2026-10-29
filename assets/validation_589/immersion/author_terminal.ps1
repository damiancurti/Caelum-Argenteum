$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Contaminacion por inmersion'
Write-Host 'CA502-IMMERSION-01. Sala privada; no modifica partidas de campana.'
Write-Host 'F1: agua biologica hasta las piernas; F2: agua salada; F3: potable; F4: quimica; F5: salir al suelo seco.'
Write-Host 'Cada tecla reinicia la contaminacion corporal para comparar. F6 abre/cierra la consola.'
Write-Host 'Mira la barra de contaminacion: aumenta en agua biologica/quimica. Salada/potable no causan esta enfermedad por contacto.'
Write-Host 'El caso concede inmunidad a la enfermedad; la respiracion conserva sus reglas. F5 permite salir del agua.'
Write-Host 'Escape cierra la introduccion. Limpieza con jabon, contactos solidos y NPC quedan pendientes.'
while($true){
 $choice=Read-Host '1 sala manual; 2 comparaciones automaticas de agua/espera; Q volver'
 if($choice -eq 'q'){break}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare immersion fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot '../run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime immersion02 -Label ('author-water-'+$stamp) -Checks -Addon immersion/checks.pk3 -Interactive -Script immersion/manual -Language es
 } elseif($choice -eq '2'){
  foreach($check in @('core','wait','departure')){
   & $runner -Runtime immersion02 -Label ('author-water-'+$check+'-'+$stamp) -Checks -Addon immersion/checks.pk3 -Script ('immersion/'+$check)
  }
 }
}
