$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $taskRoot
$Host.UI.RawUI.WindowTitle='Caelum Argenteum - Issue #235 objective marker'
function Probar235Objetivo {
    $stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File assets/validation_538/targets_run_native.ps1 -Label "author-$stamp" -Fixture probe -AdditionalFixture targets -Script targets-interactive.cfg -LoadGame c235-tracked.zds -Language esp -Interactive
}
Write-Host 'Only the new #235 spatial marker needs review; earlier checks are accepted.' -ForegroundColor Cyan
Write-Host 'F6: Argento objective. F7: Caella objective (initially unknown). F8: record her room.'
Write-Host 'F9: complete the diagnostic mission. F10: quit. Tab: Journal; M: map; +/-: zoom.'
Write-Host 'T or Track/Untrack in Missions controls the marker. Save to a new test slot.'
Write-Host 'Restart from the original test copy: Probar235Objetivo'
Probar235Objetivo
