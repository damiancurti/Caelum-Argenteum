$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Botiquines y mate'
Write-Host 'CA502-TREATMENT-01: cada 10% de Vida potencial elimina 1 de contaminacion.'
Write-Host 'F1: Vida llena, contaminacion40, botiquin mediano. Tras10 segundos:37.75.'
Write-Host 'F2: Vida llena, contaminacion40, botiquin grande y mate caliente: baja mas de5.'
Write-Host 'Espera a que termine cada dosis antes de iniciar otra. F6 abre/cierra consola.'
Write-Host 'Sala privada. La lluvia y la limpieza domestica aun no forman parte de esta prueba.'
while($true){
 $choice=Read-Host '1 prueba manual; 2 pruebas automaticas; Q salir'
 if($choice -eq 'q'){break}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare treatment fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot '../run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime treatment01 -Label ('author-treatment-'+$stamp) -Checks -Addon treatment/checks.pk3 -Interactive -Script treatment/manual -Language es
 } elseif($choice -eq '2'){
  foreach($check in @('rules','runtime','drink','save','load','hub')){
   $extra=@{};if($check -eq 'load'){$extra.LoadGame='ca502-treatment.zds'}
   & $runner -Runtime treatment01 -Label ('author-treatment-'+$check+'-'+$stamp) -Checks -Addon treatment/checks.pk3 -Script ('treatment/'+$check) @extra
  }
 }
}
