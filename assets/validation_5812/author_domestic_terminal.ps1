param([switch]$Open)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Limpieza domestica'
Write-Host 'CA502-HOUSEKEEPING-01: limpieza de una vivienda real.'
Write-Host 'F1 reinicia superficies a 80 y comienza la rutina del residente.'
Write-Host 'Mira al residente desplazarse. El panel muestra el objetivo, progreso y contaminacion.'
Write-Host 'Una superficie de 1 m2 tarda 60 segundos del mundo: 3 segundos reales en esta ciudad.'
Write-Host 'Consume 1 L de agua y 5 g de jabon. El agua se repone mientras trabaja.'
Write-Host 'F3 quita el jabon de esta prueba: el trabajo y el gasto de agua se detienen.'
Write-Host 'F4 compra jabon real: baja el dinero del cofre y el stock de Provisiones; vuelve a limpiar.'
Write-Host 'F2 informa en consola. F5 pausa/reanuda la prueba. F1 permite repetirla.'
Write-Host 'El cupo es una hora total por vivienda y dia. No hay animacion nueva de fregado.'
while($true){
    if($Open){$choice='1';$Open=$false}else{$choice=Read-Host '1 abrir; 2 pruebas automaticas; Q salir'}
    if($choice -eq 'q'){break}
    if($choice -notin @('1','2')){continue}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
    python (Join-Path $PSScriptRoot 'prepare_domestic.py')
    if($LASTEXITCODE -ne 0){throw 'Could not prepare domestic hygiene checks.'}
    $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
    $runner=Join-Path $PSScriptRoot 'run_native.ps1'
    if($choice -eq '1'){
        & $runner -Runtime domestic-final02 -Label ('author-domestic-'+$stamp) -Checks -Addon domestic-checks.pk3 -LoadGame ca502d-current.zds -Interactive -Script domestic-manual -Language es
    }else{
        foreach($check in @('core','load','hub','shortages','clock','skipped','economy')){
            $extra=@{}
            if($check -ne 'core'){$extra.LoadGame='ca502d-current.zds'}
            & $runner -Runtime domestic-final02 -Label ('author-domestic-'+$check+'-'+$stamp) -Checks -Addon domestic-checks.pk3 -StartMap MAP03 -Script ('domestic-'+$check) @extra
        }
    }
}
