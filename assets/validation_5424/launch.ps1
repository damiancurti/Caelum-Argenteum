param([string]$Directory = 'issue284-author-02')
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Host.UI.RawUI.WindowTitle = 'Caelum Argenteum #284 - author trial'
Write-Host 'F6: machete hit and burn. F7: native Zupay rock throw. F8: close rock view.'
Write-Host 'The isolated trial preserves campaign saves. Close the game to return to this terminal.'
$label = 'author-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
& (Join-Path $PSScriptRoot 'run_native.ps1') -Directory $Directory -Label $label -Script manual.cfg -Interactive
