$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Limpieza y sueno por calendario'
Write-Host 'CA502-CALENDAR-01: limpiar, dormir y reanudar la tarea.'
Write-Host '1 abre el laboratorio manual; 2 ejecuta las comprobaciones automaticas.'
Write-Host 'F1 reinicia fabricacion: quedan600s, espada contaminada80, agua5L, jabon100g y trapo.'
Write-Host 'Se limpia antes de dormir. La fabricacion debe quedar pausada en600s.'
Write-Host 'F2 muestra datos en la consola DENTRO de GZDoom. F6 vuelve al juego.'
Write-Host 'Espera hasta que diga durmiendo=1 (unos10 segundos reales en este laboratorio).'
Write-Host 'F3 simula haber recuperado el sueno: la fabricacion debe continuar.'
Write-Host 'F4 reinicia con una limpieza ya empezada: termina esa pieza sin cobrarla dos veces.'
Write-Host 'F5 reinicia sin jabon: duerme sin limpieza ni bloqueo.'
Write-Host 'F7 reinicia leyendo: conserva600s hasta despertar con F3; despues disminuyen.'
Write-Host 'F8 cancela: conserva lo limpiado y gastado; libera la tarea original.'
Write-Host 'Este laboratorio usa el reloj normal para observar las fases; la espera acelerada se verifica en opcion2.'
Write-Host 'El agua inicial esta disponible. Al dormir tambien puede beber automaticamente; la ropa puede ensuciarse de nuevo.'
Write-Host 'F1/F4/F5/F7 reinician sus propios suministros; F2 no vuelve a prepararlos.'
while($true){
 $choice=Read-Host '1 manual; 2 automaticas; Q salir'
 if($choice -eq 'q'){break}
 if($choice -notin @('1','2')){continue}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare_calendar.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare calendar-cleanup fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot 'run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime calendar-final01 -Label ('author-calendar-'+$stamp) -Checks -Addon calendar-checks.pk3 -Interactive -Script calendar-manual -Language es
 }else{
  foreach($check in @('calendar-core','calendar-edges','calendar-forecast','calendar-live','calendar-accelerated','calendar-save','calendar-load','calendar-hub')){
   $extra=@{}
   if($check -in @('calendar-load','calendar-hub')){$extra.LoadGame='ca502c-calendar.zds'}
   & $runner -Runtime calendar-final01 -Label ('author-'+$check+'-'+$stamp) -Checks -Addon calendar-checks.pk3 -Script $check -TimeoutSeconds 80 @extra
  }
 }
}
