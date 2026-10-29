param([switch]$Open)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Roce sostenido'
Write-Host 'CA502-CONTACT-01: dos cuerpos quietos, fuente 80 y receptor 20.'
Write-Host 'F1 reinicia. El receptor debe subir gradualmente; la fuente sigue en 80.'
Write-Host 'F3 separa: el receptor deja de subir. F4 junta: vuelve a subir sin reiniciarse.'
Write-Host 'F2 solo informa. F6 abre/cierra la consola. El panel se actualiza solo.'
Write-Host 'La IA y la exposicion ambiental de estos dos actores estan aisladas para ver solo el roce.'
while($true){
 if($Open){$choice='1';$Open=$false}else{$choice=Read-Host '1 abrir; 2 pruebas automaticas; Q salir'}
 if($choice -eq 'q'){break}
 if($choice -notin @('1','2')){continue}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare_contact.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare native contact fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 $runner=Join-Path $PSScriptRoot 'run_native.ps1'
 if($choice -eq '1'){
  & $runner -Runtime contact-final01 -Label ('author-contact-'+$stamp) -Checks -Addon contact-checks.pk3 -StartMap CAC502 -Interactive -Script contact-manual -Language es
 }else{
  foreach($check in @('contact-core','contact-clock','contact-save','contact-load','contact-hub')){
   $extra=@{}
   if($check -in @('contact-load','contact-hub')){$extra.LoadGame='ca502c-current.zds'}
   & $runner -Runtime contact-final01 -Label ('author-'+$check+'-'+$stamp) -Checks -Addon contact-checks.pk3 -StartMap CAC502 -Script $check @extra
  }
 }
}
