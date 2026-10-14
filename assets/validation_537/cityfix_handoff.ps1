$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $taskRoot
$Host.UI.RawUI.WindowTitle='Caelum Argenteum 5.3.7 - #234 city corrections'
function Probar234Ciudad {
    $stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File assets/validation_537/run_native.ps1 -WorkDirectory build/issue234-city-fix -Label "author-$stamp" -Fixture cityfix -Script cityfix-interactive.cfg -Map MAP06 -Language esp -Interactive
}
Write-Host 'Issue #234: corrected city gates and factory stations.' -ForegroundColor Cyan
Write-Host 'Use the blocked gate: closed padlock. F8 allows opening; Use again.'
Write-Host 'F7: southwest factory workbench. Use it, then another nearby station.'
Write-Host 'Only used stations should appear. Check native save/load.'
Write-Host 'M: map. F6: diagnostic blocked gate. F10: exit.'
Write-Host 'Positioning is diagnostic, not ordinary exploration acceptance.'
Write-Host 'This terminal stays open. Restart with Probar234Ciudad.'
Probar234Ciudad
