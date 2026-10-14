$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $taskRoot
$Host.UI.RawUI.WindowTitle='Caelum Argenteum 5.3.9 - Issue #236'
function Probar236 {
    $stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File assets/validation_539/run_native.ps1 -Label "author-$stamp" -Fixture probe -Script interactive.cfg -LoadGame c236-final-before.zds -Language esp -Interactive
}
Write-Host 'Issue #236: Explore links the existing screens. Test copy only.' -ForegroundColor Cyan
Write-Host 'Tab: Journal. N/button: Explore. M: native map. F10: exit.'
Write-Host 'This terminal stays open. Restart: Probar236'
Probar236
