$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Limpieza del equipo'
Write-Host 'CA502-CLEAN-01: limpieza manual, reparacion y antes del sueno voluntario.'
Write-Host '1: prueba manual. F1 prepara un escudo torre XL sucio, agua, jabon y trapo.'
Write-Host 'F2 abre el selector; Enter limpia. F2 otra vez cancela durante el trabajo.'
Write-Host 'Tambien se accede con J/Limpiar en el inventario sobre la pieza elegida.'
Write-Host 'F3 muestra recursos y contaminacion; F6 abre/cierra la consola.'
Write-Host 'El menu indica el coste. El tiempo del mundo corre mas rapido que el real.'
Write-Host 'Cancelar conserva lo gastado; al acabar el ambiente puede volver a ensuciar.'
Write-Host 'F4 prepara una espada sucia e inicia limpieza seguida de sueno voluntario.'
Write-Host 'Guardar/cargar conserva el trabajo; salir del mapa cancela sin reembolso.'
Write-Host '2: comprobaciones automaticas, incluida reparacion, falta de recursos y saco.'
while($true){
 $choice=Read-Host '1 manual; 2 automaticas; Q salir'
 if($choice -eq 'q'){break}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare_clean.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare cleaning fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot 'run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime clean-final06 -Label ('author-clean-'+$stamp) -Checks -Addon clean-checks.pk3 -Interactive -Script clean-manual -Language es
 } elseif($choice -eq '2'){
  foreach($check in @('clean-keys','clean-core','clean-sleep','clean-repair','clean-bag','clean-live','clean-save','clean-load','clean-hub')){
   $extra=@{};if($check -eq 'clean-load' -or $check -eq 'clean-hub'){$extra.LoadGame='ca502h-clean.zds'}
   & $runner -Runtime clean-final06 -Label ('author-'+$check+'-'+$stamp) -Checks -Addon clean-checks.pk3 -Script $check @extra
  }
 }
}
