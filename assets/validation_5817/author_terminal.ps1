$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $repo
$runtime=Join-Path $repo 'build\issue410-kitchen\current03\caelum_argenteum_dev.pk3'
if((Get-FileHash -LiteralPath $runtime).Hash.ToLowerInvariant() -ne 'be54e94db05128edffa7df957e6405ce68739785f1d11ac80c745b463b1cb381'){
    throw 'The author check requires the recorded current03 package.'
}
Write-Host '#410 - Kitchen ingredients, inventory sprites and food lots'
Write-Host '1: Interactive. F1 resets; F2 reads; F3 eats 100g beef; F4 ages food by one hour.'
Write-Host 'F5 toggles the gallery. T opens inventory; Enter uses food; C moves it into/out of the Box.'
Write-Host '2: Isolated native assertions. Q exits this terminal menu.'
while($true){
    $choice=Read-Host 'Choose'
    if($choice -eq 'q'){break}
    if($choice -notin @('1','2')){continue}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Close GZDoom first.';continue}
    python (Join-Path $PSScriptRoot 'prepare.py')
    if($LASTEXITCODE -ne 0){throw 'Could not prepare ingredient checks.'}
    $label='author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
    if($choice -eq '1'){
        & "$PSScriptRoot\run_native.ps1" -Label $label -Runtime current03 -Script manual -Language es -Checks -Interactive
    }else{
        & "$PSScriptRoot\run_native.ps1" -Label $label -Runtime current03 -Script k-core -Checks
    }
}
