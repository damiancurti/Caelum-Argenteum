$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $repo
Write-Host '#412 - Use the tent from outside with your sleeping bag'
Write-Host 'One native player. Multiplayer author checks are deferred to V5.12.'
Write-Host '1: Start outside. E uses tent; Enter rests; choose five minutes; T accelerates; Q wakes. F1 reports.'
Write-Host '2: Run outside interaction, pre-sleep cleaning and blocked-exit checks.'
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
        & "$PSScriptRoot\run_native.ps1" -Label $label -Runtime entry03 -Script entry-manual -StartMap CDEP411 -Language es -Checks -Interactive
    }elseif($choice -eq '2'){
        foreach($script in @('entry-full-ui','entry-clean','entry-exit')){
            $map=if($script -eq 'guard'){'MAP01'}else{'CDEP411'}
            & "$PSScriptRoot\run_native.ps1" -Label "$label-$script" -Runtime entry03 -Script $script -StartMap $map -Checks
        }
    }
}
