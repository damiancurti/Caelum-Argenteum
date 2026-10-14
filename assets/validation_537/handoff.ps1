param([ValidateSet('Mansion','Sewers','City')][string]$Place='Mansion')
$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $taskRoot
$Host.UI.RawUI.WindowTitle='Caelum Argenteum 5.3.7 - Issue #234'
function Probar234 {
    param([ValidateSet('Mansion','Sewers','City')][string]$Place='Mansion')
    $map=@{Mansion='MAP01';Sewers='MAP02';City='MAP06'}[$Place]
    $stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File assets/validation_537/run_native.ps1 -Label "author-$stamp" -Fixture probe -AdditionalFixture legacy -Script interactive.cfg -Map $map -Language esp -Interactive
}
Write-Host 'Issue #234: explore normally; M opens the map.' -ForegroundColor Cyan
Write-Host 'Rooms/towers: enter. Services/gates: interact. East arch: cross it.'
Write-Host 'Use copied saves. No reveal cheat is enabled.'
Write-Host 'F10 exits the engine. This terminal stays open.'
Write-Host 'Restart: Probar234 Mansion / Probar234 Sewers / Probar234 City'
Probar234 $Place
