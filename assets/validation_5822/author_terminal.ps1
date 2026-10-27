param([string]$Runtime='final22c')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $repo
Write-Host '#410 - Mansion bathroom fixtures / CA410-MANSION-BATH-01'
Write-Host '1:Rulo, 2:Ronnie, 3:Caella, 4:Argento. Each option starts a private test campaign.'
Write-Host 'Supplies: empty canteen,500g soap,40 contamination,20 toilet credit,150L shared water.'
Write-Host 'Walk and Use(E) the fixtures. Use inventory to fill the canteen or choose Bath.'
Write-Host 'The bathtub supports lying; the toilet supports sitting. Use again to leave/cancel.'
Write-Host 'Confirm clear doors/beds/tables, shared water, cleaning, save/load and hub return.'
Write-Host 'All mansion sinks/tubs/toilets share200L, replenished only1L per world minute.'
Write-Host 'Close the game before choosing another room. Q exits this terminal menu.'
while($true){
    $choice=Read-Host 'Choose'
    if($choice -eq 'q'){break}
    if($choice -notin @('1','2','3','4')){continue}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Close GZDoom first.';continue}
    python (Join-Path $PSScriptRoot 'prepare.py')
    if($LASTEXITCODE -ne 0){throw 'Could not prepare mansion bathroom checks.'}
    $index=[int]$choice-1
    $label='author-mansion-bath-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
    & "$PSScriptRoot\run_native.ps1" -Label $label -Runtime $Runtime -Script "bath-author-$index" -Language es -Checks -Addon bath-checks.pk3 -Interactive
}
