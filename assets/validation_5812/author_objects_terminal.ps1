param([switch]$Open)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Objetos y lluvia'
Write-Host 'CA502-OBJECTS-01: exposicion de dos sillas y una espada.'
Write-Host 'F1 limpia los tres objetos. Sus valores suben con el ambiente y el reloj normal.'
Write-Host 'F3 guarda la espada en la Caja: su valor se detiene. F4 la suelta: vuelve a subir.'
Write-Host 'F5 busca lluvia real y pone las sillas a 100. F6 simula 30 minutos de esa lluvia en las sillas.'
Write-Host 'La silla exterior baja 10-20 puntos por F6; la interior sigue en 100. Puede repetirse.'
Write-Host 'La lluvia no limpia por debajo del equilibrio ambiental. El panel indica los valores de los OBJETOS.'
Write-Host 'F6 integra solo esos objetos con el clima mostrado; no adelanta las demas tareas ni crea una espera pesada.'
Write-Host 'F2 informa tambien en la consola. Los controles funcionan con el menu abierto.'
while($true){
    if($Open){$choice='1';$Open=$false}else{$choice=Read-Host '1 abrir; 2 pruebas automaticas; Q salir'}
    if($choice -eq 'q'){break}
    if($choice -notin @('1','2')){continue}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
    python (Join-Path $PSScriptRoot 'prepare_objects.py')
    if($LASTEXITCODE -ne 0){throw 'Could not prepare object exposure laboratory.'}
    $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
    $runner=Join-Path $PSScriptRoot 'run_native.ps1'
    if($choice -eq '1'){
        & $runner -Runtime objects-final03 -Label ('author-objects-'+$stamp) -Checks -Addon object-checks.pk3 -StartMap CAO502 -Interactive -Script object-manual -Language es
    }else{
        foreach($check in @('object-core','object-rain','object-storage','object-save','object-load','object-hub')){
            $extra=@{}
            if($check -in @('object-load','object-hub')){$extra.LoadGame='ca502o-current.zds'}
            & $runner -Runtime objects-final03 -Label ('author-'+$check+'-'+$stamp) -Checks -Addon object-checks.pk3 -StartMap CAO502 -Script $check @extra
        }
    }
}
