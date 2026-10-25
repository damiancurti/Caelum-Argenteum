$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Posturas de inodoro y banera'
Write-Host 'CA502-POSE-01: posturas de higiene; CA502-TOILET-01 sigue disponible.'
Write-Host '1 prueba manual: F1 inodoro, F2 banera, F6 consola.'
Write-Host 'Usar inicia. Usar otra vez o moverse permite levantarse.'
Write-Host 'Inodoro: sentado; banera: acostado. El raton gira la camara.'
Write-Host 'La postura de banera aun no lava ni consume jabon; tampoco duerme.'
while($true){
 $choice=Read-Host '1 manual; 2 comprobaciones automaticas; Q salir'
 if($choice -eq 'q'){break}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare_pose.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare posture fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot 'run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime pose-final03 -Label ('author-pose-'+$stamp) -Checks -Addon pose-checks.pk3 -Interactive -Script pose-manual -Language es
 } elseif($choice -eq '2'){
  foreach($check in @('pose-core','core','live','forecast','pose-save','pose-load','pose-hub')){
   $extra=@{};if($check -eq 'pose-load' -or $check -eq 'pose-hub'){$extra.LoadGame='ca502h-pose.zds'}
   & $runner -Runtime pose-final03 -Label ('author-pose-'+$check+'-'+$stamp) -Checks -Addon pose-checks.pk3 -Script $check @extra
  }
 }
}
