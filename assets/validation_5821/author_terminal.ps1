param([string]$Runtime='final21b')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $repo
Write-Host '#411 - Camp cooking / CA411-COOKING-01'
Write-Host '1: Fish ingredients, learned recipe and loaded fire. Choose Cook (C), then Fish (2).'
Write-Host '2: Puchero ingredients, carried potable water and empty mounted pot. Choose3.'
Write-Host '3: Saved progress after fuel exhaustion/refill, in the one-minute relight phase.'
Write-Host 'T accelerates attended work after the menu closes. E uses the aimed fire.'
Write-Host 'During cooking, Use reopens progress; B opens fuel; X cancels the batch.'
Write-Host 'Cancellation keeps food/water and their age, not burned wood. Bread needs an oven.'
Write-Host 'Close the game before choosing another scenario. Q exits this terminal menu.'
while($true){
    $choice=Read-Host 'Choose'
    if($choice -eq 'q'){break}
    if($choice -notin @('1','2','3')){continue}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Close GZDoom first.';continue}
    python (Join-Path $PSScriptRoot 'prepare.py')
    if($LASTEXITCODE -ne 0){throw 'Could not prepare camp cooking checks.'}
    $scenario=@{'1'='fish';'2'='puchero';'3'='paused'}[$choice]
    $label='author-camp-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
    & "$PSScriptRoot\run_native.ps1" -Label $label -Runtime $Runtime -Script "camp-author-$scenario" -Language es -Checks -Addon camp-checks.pk3 -Interactive
}
