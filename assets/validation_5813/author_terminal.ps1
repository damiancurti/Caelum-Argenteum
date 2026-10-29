param([switch]$Open)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #411 - Fogata y olla'
Write-Host 'CA411-FIRE-01: trivet correction; previous fire/water checks are author-accepted.'
Write-Host 'The pot is already mounted above the wood, with its integral iron ring and three legs.'
Write-Host 'F1 restores the view. Walk around the pot; F2 prints its state and opens the console.'
Write-Host 'Use the fire and press P to retrieve the pot: 7.1 kg empty, 8.1 kg with the supplied 1 L.'
Write-Host 'At 100% efficiency, its recipe uses 7,100 g iron; the shop price follows that recipe.'
while($true){
    if($Open){$choice='1';$Open=$false}else{$choice=Read-Host '1 abrir prueba; 2 checks automaticos; Q salir'}
    if($choice -eq 'q'){break}
    if($choice -notin @('1','2')){continue}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
    python (Join-Path $PSScriptRoot 'prepare.py')
    if($LASTEXITCODE -ne 0){throw 'Could not prepare campfire checks.'}
    $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
    if($choice -eq '1'){
        & (Join-Path $PSScriptRoot 'run_native.ps1') -Label "author-$stamp" -Runtime trivet01 -Script trivet-manual -Checks -Interactive -Language es
    }else{
        foreach($script in @('pot','shop')){
            & (Join-Path $PSScriptRoot 'run_native.ps1') -Label "author-$script-$stamp" -Runtime trivet01 -Script $script -Checks -Language es
        }
    }
}
