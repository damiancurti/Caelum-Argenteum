$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #472 - Mate tests (5.7.14)'
$work=Join-Path $repo 'build\issue472'
Write-Host '#472 / 5.7.14 - author checks; #471 has already been accepted.'
Write-Host '1: automated native checks'
Write-Host '2: gourd mate preparation'
Write-Host '3: silver mate preparation'
Write-Host '4: gold mate preparation'
Write-Host '5: MAP03 shops/library (money, Magic Box, yerba and warm canteen)'
Write-Host '6: crafting workshop with learned recipes and materials'
Write-Host 'Q: leave this terminal open'
Write-Host ''
Write-Host 'R loads yerba. Left/Right selects bottle/canteen. F pours. Enter drinks.'
Write-Host 'V empties water. C twice discards yerba. Tab returns.'
Write-Host 'The bottle is cold; choose the warm canteen for hot benefits.'
Write-Host 'Check inventory icons, Prepare (R), quick use, contents and native save/load.'
Write-Host 'Private temperature shortcut: console netevent ca472_sample 75 1'
Write-Host 'This sets the selected mate to 75 C and one remaining hot use.'
Write-Host 'Use 59 or 86 for cold/too-hot checks. Shortcuts belong only to this test add-on.'
while($true) {
    $choice=Read-Host 'Choose 1-6 or Q'
    if($choice -eq 'q'){break}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Close the current GZDoom game first.';continue}
    $label='author-'+[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
    if($choice -eq '1'){& (Join-Path $PSScriptRoot 'run_suite.ps1') -Prefix $label;continue}
    $command=switch($choice) {
        '2' {'wait 105; language esn; netevent ca472_preview 0'}
        '3' {'wait 105; language esn; netevent ca472_preview 1'}
        '4' {'wait 105; language esn; netevent ca472_preview 2'}
        '5' {'wait 140; language esn; netevent ca472_shop_setup'}
        '6' {'wait 105; language esn; netevent ca472_workshop'}
        default {''}
    }
    if(!$command){continue}
    [IO.File]::WriteAllText((Join-Path $work "$label.cfg"),$command+"`n",[Text.UTF8Encoding]::new($false))
    $extra=@{Checks=$true}
    if($choice -eq '5'){$extra.StartMap='MAP03'}
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Label $label -Runtime current -Script $label -Interactive @extra
}
