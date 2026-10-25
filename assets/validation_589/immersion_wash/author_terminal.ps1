$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Lavado por inmersion'
Write-Host 'CA502-WASH-01: agua potable limpia el cuerpo segun superficie sumergida y masa.'
Write-Host 'F1: contaminacion40, inmersion completa. F2: parcial, baja mas despacio.'
Write-Host 'F3: salir sin reiniciar contaminacion; debe dejar de bajar por inmersion.'
Write-Host 'F4: agua salada, contaminacion40; no limpia. F5: agua biologica; contamina.'
Write-Host 'F6: consola. Sala privada; F1/F2/F4 protegen de muerte por ahogamiento.'
Write-Host 'Esta prueba no incluye banera, inodoro ni limpieza domestica.'
while($true){
 $choice=Read-Host '1 prueba manual; 2 pruebas automaticas; Q salir'
 if($choice -eq 'q'){break}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare immersion-washing fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot '../run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime wash01 -Label ('author-wash-'+$stamp) -Checks -Addon immersion_wash/checks.pk3 -Interactive -Script immersion_wash/manual -Language es
 } elseif($choice -eq '2'){
  foreach($check in @('core','wait','regression','save','load','hub')){
   $extra=@{};if($check -eq 'load' -or $check -eq 'hub'){$extra.LoadGame='ca502-wash.zds'}
   & $runner -Runtime wash01 -Label ('author-wash-'+$check+'-'+$stamp) -Checks -Addon immersion_wash/checks.pk3 -Script ('immersion_wash/'+$check) @extra
  }
 }
}
