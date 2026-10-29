$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #411 - Carpa y olla: inventario y comercio'
Write-Host 'CA411-EQUIPMENT-01: adquisicion. Montaje, fogata y cocina siguen pendientes.'
Write-Host '1 abre una sala privada con carpa, dos ollas, dinero de prueba y cofre.'
Write-Host 'La carpa y una olla estan en la Caja. Abri el inventario habitual.'
Write-Host 'Revisa iconos, nombres, 10 kg de carpa y 5,5 kg de olla vacia.'
Write-Host 'Las ollas tienen 2 L potables y 1 L contaminado: no deben mezclarse.'
Write-Host 'Proba Caja, soltar/recoger, guardar/cargar y depositar/retirar del cofre.'
Write-Host 'F1 abre Provisiones: compra varias ollas o carpas; vende y recompra una olla usada.'
Write-Host 'Cada objeto debe conservar su identidad y el agua de su propia olla.'
Write-Host '2 ejecuta las pruebas automaticas de esta etapa, una ventana por vez.'
while($true){
    $choice=Read-Host '1 sala; 2 comprobaciones; Q deja la terminal abierta'
    if($choice -eq 'q'){break}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero la otra ventana de GZDoom.';continue}
    $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
    if($choice -eq '1'){
        & (Join-Path $PSScriptRoot 'run_native.ps1') -Label ('author-camp-'+$stamp) -Checks -Interactive -Script interactive -Language es
    } elseif($choice -eq '2'){
        foreach($check in @('physics','items','craft','shop','transfer')){
            & (Join-Path $PSScriptRoot 'run_native.ps1') -Label ('author-'+$check+'-'+$stamp) -Checks -Script $check
        }
    }
}
