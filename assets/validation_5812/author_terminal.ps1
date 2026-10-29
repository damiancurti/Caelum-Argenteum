$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Inodoro e higiene'
Write-Host 'CA502-TOILET-01: uso metabolico del inodoro.'
Write-Host '1 inicia delante del inodoro de una vivienda. F1 reinicia el escenario.'
Write-Host 'Estado de prueba: contaminacion40, capacidad20, reserva100 L.'
Write-Host 'Usar inicia; usar otra vez o alejarse cancela. F6 abre la consola.'
Write-Host 'Al completar un minuto del mundo: hasta20 de limpieza y10 L gastados.'
Write-Host 'La regeneracion y la reposicion de agua siguen transcurriendo.'
Write-Host 'No incluye aun bano con jabon ni limpieza del equipo.'
while($true){
 $choice=Read-Host '1 prueba manual; 2 pruebas automaticas; Q salir'
 if($choice -eq 'q'){break}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare hygiene fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot 'run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime final01 -Label ('author-toilet-'+$stamp) -Checks -Interactive -Script manual -Language es
 } elseif($choice -eq '2'){
  foreach($check in @('core','live','forecast','save','load','hub')){
   $extra=@{};if($check -eq 'load' -or $check -eq 'hub'){$extra.LoadGame='ca502h-session.zds'}
   & $runner -Runtime final01 -Label ('author-toilet-'+$check+'-'+$stamp) -Checks -Script $check @extra
  }
 }
}
