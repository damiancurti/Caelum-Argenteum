$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #471 - Chemistry and fermentation tests'
$work=Join-Path $repo 'build\issue471-batches'
Write-Host '#471 / 5.7.13 - author checks (independent of #472)'
Write-Host '1: automated production checks'
Write-Host '2: barrel interaction (1 L supplies and learned recipe)'
Write-Host '3: Chemistry energy-drink recipe, ready to craft'
Write-Host '4: new supply models'
Write-Host '5: MAP03 shops and library'
Write-Host 'Q: leave the terminal open without starting a game'
Write-Host ''
Write-Host 'Barrel: arrows/B/V change quantity, Home/End min/max, Enter starts/collects.'
Write-Host 'C twice discards. Held C must not discard. Tab returns; Use reopens.'
Write-Host 'For the private barrel check only: console netevent ca471i_preview 2 advances 72 world hours.'
Write-Host 'Check partial collection, remaining contents, save/load and retained bottle.'
Write-Host 'Chemistry: craft/cancel/wait; inputs are spent only on completion.'
while($true) {
    $choice=Read-Host 'Choose 1-5 or Q'
    if($choice -eq 'q'){break}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Close the current GZDoom game first.';continue}
    $label='author-'+[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
    if($choice -eq '1') {
        & (Join-Path $PSScriptRoot 'run_suite.ps1') -Prefix $label -Runtime current
        continue
    }
    $command=switch($choice) {
        '2' {'wait 105; language esn; netevent ca471i_preview 0'}
        '3' {'wait 105; language esn; netevent ca471i_preview 3'}
        '4' {'wait 105; language esn; netevent ca471i_preview 0; wait 5; netevent ca471i_preview 4'}
        '5' {'wait 105; language esn'}
        default {''}
    }
    if(!$command){continue}
    [IO.File]::WriteAllText((Join-Path $work "$label.cfg"),$command+"`n",[Text.UTF8Encoding]::new($false))
    $extra=@{Checks=$true;Addon='integration-checks.pk3'}
    if($choice -eq '5'){$extra=@{StartMap='MAP03'}}
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Label $label -Runtime current -Script $label -Interactive @extra
}
