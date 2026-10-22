param([ValidateSet('combat','gallery')][string]$Mode='combat')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Push-Location -LiteralPath $repo
try {
    & python (Join-Path $PSScriptRoot 'prepare.py')
    if($LASTEXITCODE -ne 0){throw 'Fixture preparation failed.'}
    $script=if($Mode -eq 'gallery'){'gallery-interactive'}else{'interactive'}
    $label='author-'+$Mode+'-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Label $label -Checks -Script $script -Interactive
    Write-Host 'CA479-01: GZDoom is open. Keep this terminal open for the author.'
    if($Mode -eq 'combat'){
        Write-Host 'F1: next implement; F2: reset resources; F3: Charisma/Empathy 0 or 100; F4: enemy seal.'
        Write-Host 'Slot 0: support. Primary: aim at enemy/ally. Secondary: self benefit. R: no support charge.'
        Write-Host 'This private scene suspends natural Anima regeneration; F2 refills it.'
    }else{Write-Host 'F1: cycle six implements and their three tiers (18 views).'}
    Write-Host 'Report the result before CA479-01 can be accepted.'
} finally {Pop-Location}
