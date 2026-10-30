$ErrorActionPreference = 'Stop'
$Host.UI.RawUI.WindowTitle = 'Caelum Argenteum 5.9 - Pruebas por issue'
& python -X utf8 (Join-Path $PSScriptRoot 'handoff.py')
if ($LASTEXITCODE -ne 0) {
    Write-Host 'The review launcher stopped with an error. Preserve the displayed log path.'
    Read-Host 'Press Enter to return'
}
