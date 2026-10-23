param([switch]$StartNow)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Host.UI.RawUI.WindowTitle='Caelum #409 - Water boiling test'
Set-Location -LiteralPath $repo
Write-Host 'Issue #409: boiling and bottle/canteen cooling. This terminal stays open.'
Write-Host 'The private scene supplies water, coal, Workbench and Alchemy.'
Write-Host 'Inventory H starts boiling; crafting C cancels; Y opens ordinary waiting.'
Write-Host 'F1 resets the private inputs. F2 cycles biological / salty / chemical combinations.'
Write-Host 'After boiling, wait to a later time to cool water before drinking.'
if(!$StartNow){Read-Host 'Press Enter when you return and want to start' | Out-Null}
$label='author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
& (Join-Path $PSScriptRoot 'run_native.ps1') -Label $label -Checks -Script interactive -Interactive
Write-Host 'The game is running. Keep this terminal for the test log and any errors.'
