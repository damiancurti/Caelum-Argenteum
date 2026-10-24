$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #415 - Noticias al regresar'
Write-Host 'CA415-DISCOVERY-01: conocimiento de eventos, etapa parcial de #415.'
Write-Host 'La simulacion de asedios fuera del mapa sigue pendiente.'
Write-Host '1 abre una sala privada. F1 va a la region del evento; F2 vuelve; F3 imprime estado.'
Write-Host 'Antes de F1: el evento remoto ya ocurrio, pero no debe avisarte ni figurar como confirmado en el Calendario.'
Write-Host 'Tras F1: aparece un solo aviso; el Calendario confirma el resultado.'
Write-Host 'Alterna F2/F1: no debe repetir el aviso. F3 muestra actual=1, conocido=1, avisos=1.'
Write-Host 'Guardar/cargar debe conservar ambos contadores; no se alteran tus partidas de campana.'
while($true){
    $choice=Read-Host '1 iniciar; Q deja esta terminal abierta'
    if($choice -eq 'q'){break}
    if($choice -ne '1'){continue}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero la otra ventana de GZDoom.';continue}
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Label ('author-'+[DateTime]::Now.ToString('yyyyMMdd-HHmmss')) -Checks -Interactive -Script interactive
}
