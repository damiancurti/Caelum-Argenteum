$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $taskRoot
$Host.UI.RawUI.WindowTitle='Caelum Argenteum 5.3.8 - Issue #235'
function Probar235 {
    $stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File assets/validation_538/run_native.ps1 -Label "author-$stamp" -Fixture probe -AdditionalFixture legacy -Script interactive.cfg -LoadGame c235-tracked.zds -Language esp -Interactive
}
Write-Host 'Issue #235: diagnostic copy with three active tracked missions.' -ForegroundColor Cyan
Write-Host 'Journal > Missions: T or Track. Native map: M. F8: terminal-state fixture.'
Write-Host 'F10 exits the engine. This terminal stays open. Restart: Probar235'
Probar235
