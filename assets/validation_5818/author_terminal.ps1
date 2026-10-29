$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $repo
$runtime=Join-Path $repo 'build\issue410-cooking\current05\caelum_argenteum_dev.pk3'
if((Get-FileHash -LiteralPath $runtime).Hash.ToLowerInvariant() -ne '9a243426e2647b7573e593766a862004ccf3b7683254cfe07dbb028f5cc0cf2f'){
    throw 'The author check requires the recorded current05 package.'
}
Write-Host '#410 - Prepared meals: sprites, portions and food lots'
Write-Host '1: Interactive. F1 resets; F2 reads; F3 eats 100g bread; F4 ages only food by six hours at 20C / 50% RH.'
Write-Host 'F5 toggles the gallery. T opens inventory; Enter uses food; C moves it into/out of the Box.'
Write-Host '2: Isolated native assertions. 3: Real table with four meals. Q exits this terminal menu.'
while($true){
    $choice=Read-Host 'Choose'
    if($choice -eq 'q'){break}
    if($choice -notin @('1','2','3')){continue}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Close GZDoom first.';continue}
    python (Join-Path $PSScriptRoot 'prepare.py')
    if($LASTEXITCODE -ne 0){throw 'Could not prepare meal checks.'}
    $label='author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
    if($choice -in @('1','3')){
        $scenario=if($choice -eq '3'){'table-manual'}else{'manual'}
        & "$PSScriptRoot\run_native.ps1" -Label $label -Runtime current05 -Script $scenario -Language es -Checks -Interactive
    }else{
        & "$PSScriptRoot\run_native.ps1" -Label $label -Runtime current05 -Script m-core -Checks
    }
}
