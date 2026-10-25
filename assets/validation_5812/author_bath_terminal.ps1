$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Bano con jabon'
Write-Host 'CA502-BATH-01: bano progresivo, agua real y sobrante de jabon.'
Write-Host '1 manual: F1 reinicia; H en inventario o F2 abre el selector.'
Write-Host 'Elegir puntos, Enter inicia. Moverse cancela conservando lo gastado.'
Write-Host 'F3 informa contaminacion, agua y jabon; F6 abre la consola.'
Write-Host 'La banera conserva la postura acostada. Los costes dependen de la masa.'
Write-Host 'Guardar/cargar conserva el progreso; salir del mapa cancela sin reembolso.'
while($true){
 $choice=Read-Host '1 manual; 2 comprobaciones automaticas; Q salir'
 if($choice -eq 'q'){break}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare_bath.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare bath fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot 'run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime bath-final05 -Label ('author-bath-'+$stamp) -Checks -Addon bath-checks.pk3 -Interactive -Script bath-manual -Language es
 } elseif($choice -eq '2'){
  foreach($check in @('bath-core','bath-live','bath-water','bath-save','bath-load','bath-hub')){
   $extra=@{};if($check -eq 'bath-load' -or $check -eq 'bath-hub'){$extra.LoadGame='ca502h-bath.zds'}
   if($check -eq 'bath-water'){$extra.StartMap='MAP01'}
   & $runner -Runtime bath-final05 -Label ('author-'+$check+'-'+$stamp) -Checks -Addon bath-checks.pk3 -Script $check @extra
  }
 }
}
