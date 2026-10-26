param([switch]$Open)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #411 - Fogata y olla'
Write-Host 'CA411-FIRE-01: fogata, lena y olla. No incluye recetas de comida.'
Write-Host 'La escena aporta 20 kg de lena y una olla con 1 L a 20 C, con las tres contaminaciones.'
Write-Host 'F1 abre el montaje de prueba. En una partida: usar lena desde el inventario.'
Write-Host 'Enter monta/enciende en un minuto del mundo. Se puede esperar o acelerar la tarea.'
Write-Host 'Usar la fogata abre su panel: Enter enciende/apaga; R carga; V recupera; D desmonta.'
Write-Host 'P coloca/retira la olla. N elige entre las ollas que llevas fuera de la Caja.'
Write-Host 'F2 informa combustible, calor y agua en consola. F3 simula 60 segundos SOLO de la fogata.'
Write-Host 'F4 simula el calentamiento y hervor SOLO de la fogata: desaparece la biologica; sal y quimica permanecen.'
Write-Host 'F3/F4 son atajos de laboratorio. El juego normal usa el calendario real, incluido esperar.'
Write-Host 'Apagar conserva lena; sin olla, desmontar tarda un minuto. Viajar apaga y conserva el combustible.'
while($true){
    if($Open){$choice='1';$Open=$false}else{$choice=Read-Host '1 abrir prueba; 2 checks automaticos; Q salir'}
    if($choice -eq 'q'){break}
    if($choice -notin @('1','2')){continue}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
    python (Join-Path $PSScriptRoot 'prepare.py')
    if($LASTEXITCODE -ne 0){throw 'Could not prepare campfire checks.'}
    $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
    if($choice -eq '1'){
        & (Join-Path $PSScriptRoot 'run_native.ps1') -Label "author-$stamp" -Runtime final05 -Script manual -Checks -Interactive -Language es
    }else{
        foreach($script in @('core','pot','wait','ui')){
            & (Join-Path $PSScriptRoot 'run_native.ps1') -Label "author-$script-$stamp" -Runtime final05 -Script $script -Checks -Language es
        }
    }
}
