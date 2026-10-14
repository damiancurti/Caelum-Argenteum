$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $taskRoot
$Host.UI.RawUI.WindowTitle='Caelum Argenteum - #234 grate marker correction'
function Probar234Reja {
    $stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File assets/validation_537/run_native.ps1 -WorkDirectory build/issue234-marker-fix -Label "author-$stamp" -Fixture marker -Script marker-interactive.cfg -Map MAP02 -Language esp -Interactive
}
Write-Host 'Issue #234: isolated diagnostic position facing one locked grate.' -ForegroundColor Cyan
Write-Host 'Use before F8: closed label and lock. F8 gives this grate key; Use opens it.'
Write-Host 'M: map. The open grate must show the passage icon and open label.'
Write-Host 'F10 exits; Probar234Reja restarts. Other saves/sessions stay intact.'
Probar234Reja
