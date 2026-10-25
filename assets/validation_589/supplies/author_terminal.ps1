$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Jabón, trapo e inmersión'
Write-Host 'CA502-SUPPLIES-01: adquisición y fabricación. La limpieza/baño siguen pendientes.'
Write-Host 'Sala privada; no modifica tus partidas de campaña.'
Write-Host 'F2 abre Provisiones para comprar/vender. F4 abre inventario: revisa los sprites de grasa, sosa, jabón y trapo.'
Write-Host 'F3 abre fabricación con jabón seleccionado. También puedes elegir Trapo de limpieza.'
Write-Host 'Jabón: 1 kg grasa +135 g sosa +2058 g carbón +300 mL potable ->1 kg;2 horas del mundo.'
Write-Host 'Trapo:100 g de tela de algodón a eficiencia100%; sigue tiempo y desperdicio normales.'
Write-Host 'La sala aporta materiales, dinero, recetas aprendidas y una cantimplora potable.'
Write-Host 'Escape cierra la introducción; F6 abre/cierra consola. Guarda/carga en la sala si quieres comprobarlo.'
while($true){
 $choice=Read-Host '1 suministros manual; 2 pruebas automáticas; 3 prueba pendiente de inmersión; Q salir'
 if($choice -eq 'q'){break}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare supplies fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot '../run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime supplies02 -Label ('author-supplies-'+$stamp) -Checks -Addon supplies/checks.pk3 -Interactive -Script supplies/manual -Language es
 } elseif($choice -eq '2'){
  foreach($check in @('craft','shop','transfer')){
   & $runner -Runtime supplies02 -Label ('author-supplies-'+$check+'-'+$stamp) -Checks -Addon supplies/checks.pk3 -Script ('supplies/'+$check)
  }
 } elseif($choice -eq '3') { & (Join-Path $PSScriptRoot '../immersion/author_terminal.ps1') }
}
