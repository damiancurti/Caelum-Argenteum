param([ValidatePattern('^issue322-[a-z0-9_-]+$')][string]$Directory = 'issue322-preview02')
$ErrorActionPreference = 'Stop'
$previewRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $previewRoot
Write-Host 'Issue #322: four released prisoners, a narrow corridor, a usable door and two corners.'
Write-Host 'Walk, stop and reverse direction. In the narrowest passage both bodies may need to move aside.'
Write-Host 'Use the door normally; speak with a prisoner and check that it stops, then resumes following.'
Write-Host 'Save/load using only this isolated preview. Close GZDoom when finished; this terminal remains open.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5422/run_native.ps1 `
    -Directory $Directory -Label author-preview -Script manual.cfg -Map MAP97 -Interactive
if ($LASTEXITCODE -ne 0) { throw 'Preview runner failed; inspect the preserved native log.' }
