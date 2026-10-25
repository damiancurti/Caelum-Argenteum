$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Superficies y lluvia'
Write-Host 'CA502-SURFACE-01: contaminacion del suelo y paredes, lavado por lluvia.'
Write-Host '1 abre el laboratorio. F1 prepara suelo80/cuerpo0. F2 muestra valores.'
Write-Host 'F3 prepara contacto con pared. F6 abre/cierra la consola.'
Write-Host 'F4 prepara lluvia real: una zona exterior y una interior empiezan en100.'
Write-Host 'F5 avanza30 minutos del mundo; F2 compara ambas zonas.'
Write-Host 'La lluvia limpia afuera y conserva el interior. Se puede repetir F5.'
Write-Host 'El equipo que cubre pies/torso recibe primero el contacto; F2 lo muestra.'
Write-Host '2 ejecuta las comprobaciones automaticas de este cambio.'
while($true){
 $choice=Read-Host '1 manual; 2 automaticas; Q salir'
 if($choice -eq 'q'){break}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare_surface.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare surface fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot 'run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime surface-final05 -Label ('author-surface-'+$stamp) -Checks -Addon surface-checks.pk3 -Interactive -StartMap CAS502 -Script surface-manual -Language es
 } elseif($choice -eq '2'){
  foreach($check in @('surface-rules','surface-native','surface-weather','surface-rain-live','surface-save','surface-load','surface-hub','surface-forecast')){
   $extra=@{StartMap='CAS502'}
   if($check -eq 'surface-load' -or $check -eq 'surface-hub'){$extra.LoadGame='ca502s-surfaces.zds'}
   if($check -eq 'surface-forecast'){$extra.StartMap='CAH000'}
   & $runner -Runtime surface-final05 -Label ('author-'+$check+'-'+$stamp) -Checks -Addon surface-checks.pk3 -Script $check @extra
  }
 }
}
