$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $repo
Write-Host '#412 - Sleeping bag clearance inside the accepted tent'
Write-Host 'One native player. Multiplayer author checks are deferred to V5.12.'
Write-Host '1: Play the private fixture. F1 returns to the first berth; F2 sleeps; F3 wakes; F4 reports.'
Write-Host '2: Run the focused native geometry, solo acceleration and packing checks.'
Write-Host 'Q: Exit this menu.'
while($true){
    $choice=Read-Host 'Choose'
    if($choice -eq 'q'){break}
    if($choice -notin @('1','2')){continue}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Close GZDoom first.';continue}
    python (Join-Path $PSScriptRoot 'prepare.py')
    if($LASTEXITCODE -ne 0){throw 'Could not prepare sleeping-bag checks.'}
    $label='author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
    if($choice -eq '1'){
        & "$PSScriptRoot\run_native.ps1" -Label $label -Runtime final02 -Script manual -StartMap CDEP411 -Language es -Checks -Interactive
    }elseif($choice -eq '2'){
        foreach($script in @('core','fast','guard')){
            $map=if($script -eq 'guard'){'MAP01'}else{'CDEP411'}
            & "$PSScriptRoot\run_native.ps1" -Label "$label-$script" -Runtime final02 -Script $script -StartMap $map -Checks
        }
    }
}
