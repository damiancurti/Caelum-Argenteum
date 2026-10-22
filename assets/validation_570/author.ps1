param([string]$Label = 'author-01')
$Host.UI.RawUI.WindowTitle = 'Caelum Argenteum 5.7.0 - #408 water acceptance'
Write-Host '#408 private water-quality test. Campaign saves are untouched.'
Write-Host 'F1 potable | F2 biological | F3 salt | F4 chemical | F5 mixed'
Write-Host 'Tab: Inventory. Select the canteen. R: collect. V: empty. Enter: drink.'
Write-Host 'Collect water and Empty also have mouse buttons. Save/reload in this private session.'
Write-Host 'Boiling belongs to #409 and is not included in this test.'
& (Join-Path $PSScriptRoot 'run_native.ps1') -Label $Label -Checks -Script interactive -Interactive
Write-Host 'The game has been launched. This terminal remains open for your test.'
