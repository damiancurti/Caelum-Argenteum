$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Limpieza al despertar'
Write-Host 'CA502-WAKE-01: limpieza despues de un desmayo por agotamiento.'
Write-Host '1 abre la prueba manual. El personaje comienza dormido por agotamiento.'
Write-Host 'F1 reinicia: espada contaminada80, agua5L, jabon100g y trapo.'
Write-Host 'F2 simula la recuperacion minima, despierta y muestra la limpieza iniciada.'
Write-Host 'Los datos aparecen en la consola DENTRO de GZDoom; F6 vuelve al juego.'
Write-Host 'F3 muestra dormido, limpieza, contaminacion del arma, agua y jabon.'
Write-Host 'Tras F2, cierra la consola con F6 y espera unos segundos; F3 comprueba el resultado.'
Write-Host 'Debe terminar despierto. El arma se limpia primero, luego la ropa equipada.'
Write-Host 'Beber automaticamente durante el sueno puede gastar agua aparte de la limpieza.'
Write-Host 'La exposicion ambiental sigue activa: una pieza ya limpia puede volver a ensuciarse.'
Write-Host 'F4 reinicia sin jabon y despierta: no debe bloquearse ni limpiar gratis.'
Write-Host '2 ejecuta comprobaciones automaticas del despertar y sus guardados.'
while($true){
 $choice=Read-Host '1 manual; 2 automaticas; Q salir'
 if($choice -eq 'q'){break}
 if($choice -notin @('1','2')){continue}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare_wake.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare exhaustion-wake fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot 'run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime wake-final01 -Label ('author-wake-'+$stamp) -Checks -Addon wake-checks.pk3 -Interactive -StartMap CAH000 -Script wake-manual -Language es
 }else{
  foreach($check in @('wake-core','wake-live','wake-save','wake-load','wake-hub')){
   $extra=@{}
   if($check -eq 'wake-load' -or $check -eq 'wake-hub'){$extra.LoadGame='ca502w-cleaning.zds'}
   & $runner -Runtime wake-final01 -Label ('author-'+$check+'-'+$stamp) -Checks -Addon wake-checks.pk3 -StartMap CAH000 -Script $check @extra
  }
 }
}
