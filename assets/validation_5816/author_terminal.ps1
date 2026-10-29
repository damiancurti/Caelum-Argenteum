$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $repo
Write-Host '#502 - Physical scenery exposure and washing'
Write-Host '1: Interactive. F1 sets 80; F4 washes to 60, then 40. F3 starts at 20 and exposes. F2 records values.'
Write-Host '2: Run the isolated native checks.'
Write-Host 'These readings describe scenery, not the player. Q exits this menu.'
while($true){
    $choice=Read-Host 'Choose'
    if($choice -eq 'q'){break}
    if($choice -notin @('1','2')){continue}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Close GZDoom first.';continue}
    python (Join-Path $PSScriptRoot 'prepare.py')
    if($LASTEXITCODE -ne 0){throw 'Could not prepare scenery checks.'}
    $label='author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
    if($choice -eq '1'){
        & "$PSScriptRoot\run_native.ps1" -Label $label -Runtime current03 -Script manual -Language es -Checks -Interactive
    }else{
        & "$PSScriptRoot\run_native.ps1" -Label $label -Runtime current03 -Script core -Checks
    }
}
