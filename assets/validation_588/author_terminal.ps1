$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #411 - Colocacion de cofres'
Write-Host 'CA411-PLACEMENT-01: suelo y accesos; permisos de terreno y carpa siguen pendientes.'
Write-Host '1 abre una sala privada llevando un cofre pequeno con tres botiquines.'
Write-Host 'F2 va al escalon, F3 al agua y F4 a una puerta abierta: F5 debe rechazar colocar.'
Write-Host 'F6 informa el contenido: siempre deben quedar tres botiquines en el mismo cofre.'
Write-Host 'Finalmente F1 lleva a suelo libre; F5 coloca el cofre. Abrilo con la interaccion habitual.'
Write-Host 'Proba guardar/cargar mientras lo transportas y despues de colocarlo.'
Write-Host '2 ejecuta las comprobaciones automaticas, una ventana por vez.'
while($true){
    $choice=Read-Host '1 sala; 2 comprobaciones; Q deja la terminal abierta'
    if($choice -eq 'q'){break}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero la otra ventana de GZDoom.';continue}
    $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
    if($choice -eq '1'){
        & (Join-Path $PSScriptRoot 'run_native.ps1') -Label ('author-placement-'+$stamp) -Checks -Interactive -Script interactive -Language es
    } elseif($choice -eq '2'){
        foreach($check in @('core','storage')){
            & (Join-Path $PSScriptRoot 'run_native.ps1') -Label ('author-'+$check+'-'+$stamp) -Checks -Script $check
        }
    }
}
