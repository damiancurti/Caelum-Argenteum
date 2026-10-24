$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #411 - Compra y alquiler de vivienda'
Write-Host 'CA411-PROPERTY-01: vivienda central. Campamentos siguen pendientes.'
Write-Host '1 inicia una partida privada en la casa real; no modifica tus partidas.'
Write-Host 'Recibis dinero de prueba y un cofre propio con dos raciones.'
Write-Host 'R alquila por 1000 cobres / 30 dias. B compra por 100000 cobres.'
Write-Host 'Tab cierra el panel. Enter cruza a MAP03; usar la puerta permite volver.'
Write-Host 'F1 adelanta 31 dias: alquiler vencido impide descansar/depositar; permite retirar.'
Write-Host 'Reabri el panel para renovar. Una compra no vence ni devuelve alquileres.'
Write-Host 'Proba guardar/cargar, entrar/salir y conservar tus objetos sin duplicados.'
Write-Host 'La casa vecina CAH070 conserva los residentes y su cofre cerrado original.'
Write-Host 'Reinicia con 1 para probar compra y alquiler por separado.'
while($true){
    $choice=Read-Host '1 iniciar; Q deja la terminal abierta'
    if($choice -eq 'q'){break}
    if($choice -ne '1'){continue}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero la otra ventana de GZDoom.';continue}
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Label ('author-'+[DateTime]::Now.ToString('yyyyMMdd-HHmmss')) -Checks -Interactive -Script interactive -StartMap CAH069 -Language es
}
