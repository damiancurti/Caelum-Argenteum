param([switch]$Open)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #410 - Lotes de comida'
Write-Host 'CA410-FOOD-01: raciones, contaminacion y lotes. No incluye recetas nuevas.'
Write-Host 'F1 repone tres porciones viejas con contaminacion30 y tres frescas.'
Write-Host 'El inventario indica la contaminacion de la proxima porcion y el numero de lotes.'
Write-Host 'F2 imprime cantidad, lotes, contaminacion corporal, masa y dosis siguiente; abre/cierra consola.'
Write-Host 'F3 consume una racion mediante el uso nativo. Primero se gastan las tres viejas.'
Write-Host 'La dosis corporal corresponde a200g y80kg/masa; la barra no supera100.'
Write-Host 'F4 envejece SOLO la comida24h con su clima guardado. Es un atajo de laboratorio.'
Write-Host 'En juego normal el calendario incluye espera/viaje; la Caja no frena el deterioro.'
Write-Host 'Puedes guardar/cargar y usar cofres. Cambiar de recipiente no vuelve fresca la comida.'
Write-Host 'Las tiendas rechazan comida con cualquier contaminacion; su stock propio sigue fresco.'
while($true){
    if($Open){$choice='1';$Open=$false}else{$choice=Read-Host '1 abrir prueba; 2 checks automaticos; Q salir'}
    if($choice -eq 'q'){break}
    if($choice -notin @('1','2')){continue}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
    python (Join-Path $PSScriptRoot 'prepare.py')
    if($LASTEXITCODE -ne 0){throw 'Could not prepare food checks.'}
    $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
    if($choice -eq '1'){
        & (Join-Path $PSScriptRoot 'run_native.ps1') -Label "author-$stamp" -Runtime final01 -Script manual -Checks -Interactive -Language es
    }else{
        foreach($script in @('core','clock','travel','container')){
            & (Join-Path $PSScriptRoot 'run_native.ps1') -Label "author-$script-$stamp" -Runtime final01 -Script $script -Checks -Language es
        }
    }
}
