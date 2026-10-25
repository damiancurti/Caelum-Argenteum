$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #410 - Banos y agua domestica'
Write-Host 'CA410-BATH-01: sanitarios y reserva compartida por vivienda.'
Write-Host 'F1 fregadero; F2 banera; F3 inodoro (solo aspecto en esta entrega).'
Write-Host 'Usar muestra litros disponibles. Inventario > botella > Recoger agua.'
Write-Host 'F4 otra casa; F5 regresar. Cada casa conserva su propia reserva.'
Write-Host 'F7 vacia la botella de prueba sin devolver agua a la reserva; F6 consola.'
Write-Host 'Revisa modelos, acceso, llenado compartido, guardado y regreso.'
Write-Host 'Esta prueba no incluye uso metabolico del inodoro ni bano con jabon.'
while($true){
 $choice=Read-Host '1 prueba manual; 2 pruebas automaticas; Q salir'
 if($choice -eq 'q'){break}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare bathroom fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot 'run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime final07 -Label ('author-bath-'+$stamp) -Checks -Interactive -Script manual -Language es
 } elseif($choice -eq '2'){
  foreach($check in @('core','house','fill','save','load','hub')){
   $extra=@{};if($check -eq 'load' -or $check -eq 'hub'){$extra.LoadGame='ca410b-water.zds'}
   & $runner -Runtime final07 -Label ('author-bath-'+$check+'-'+$stamp) -Checks -Script $check @extra
  }
 }
}
