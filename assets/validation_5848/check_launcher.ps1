$ErrorActionPreference='Stop'
$repo=(Resolve-Path "$PSScriptRoot/../..").Path
$label='missing-save-guard'
$missing='deliberately-absent-5848.zds'
if(Test-Path -LiteralPath "$repo/build/issue502-vessels/$missing") {throw 'Guard fixture requires an absent save'}
try {
    & "$PSScriptRoot/run_native.ps1" -Label $label -LoadGame $missing
    throw 'Missing save was accepted'
} catch {
    if($_.Exception.Message -notlike 'Required save does not exist; refusing to launch GZDoom:*'){throw}
}
if((Get-Process gzdoom -ErrorAction SilentlyContinue) -or
    (Test-Path -LiteralPath "$repo/build/issue502-vessels/$label.ini")) {throw 'Rejected load started a native session'}
Write-Output 'PASS: absent save rejected before config creation or native launch'
