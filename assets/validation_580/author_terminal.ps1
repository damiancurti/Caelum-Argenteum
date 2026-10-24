$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #414 - Connected water feasibility (5.8.0)'
Write-Host '#414 / 5.8.0 - private connected-water feasibility test'
Write-Host '1: open a fresh interactive water room'
Write-Host '2: load your private saved game (filename required)'
Write-Host 'Q: leave this terminal open'
Write-Host ''
Write-Host 'F1 opens the gate; F2 stops transfer by closing it.'
Write-Host 'F3/F4 enter the left/right basin; F5 returns to the dry walkway.'
Write-Host 'F6 prints levels in the console; F7 shows both basins from above.'
Write-Host 'Close the console to see the scene. Use Escape to save/load.'
Write-Host 'Initial levels: left 192, right 32. Both settle at 112.'
Write-Host 'Save midway with the gate open or closed; reload and check continuity.'
Write-Host 'This stage proves geometry and persistence only. Quality mixing and campaign placement are pending.'
while($true) {
    $choice=Read-Host 'Choose 1, 2 or Q'
    if($choice -eq 'q'){break}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Close the current GZDoom game first.';continue}
    if($choice -notin @('1','2')){continue}
    $label='author-'+[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
    $options=@{Label=$label;Checks=$true;Interactive=$true;Script='interactive'}
    if($choice -eq '2') {
        $name=Read-Host 'Saved filename under build/issue414 (for example save0.zds)'
        if([IO.Path]::GetFileName($name) -ne $name -or !$name.EndsWith('.zds') -or
            !(Test-Path -LiteralPath (Join-Path $repo "build/issue414/$name"))) {
            Write-Host 'Choose an existing .zds filename in this private save directory.';continue
        }
        $options.LoadGame=$name
        $options.Script='resume'
    }
    & (Join-Path $PSScriptRoot 'run_native.ps1') @options
}
