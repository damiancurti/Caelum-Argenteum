param([ValidatePattern('^issue324-[a-z0-9_-]+$')][string]$Directory = 'issue324-final17')
$ErrorActionPreference = 'Stop'
$previewRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $previewRoot
Write-Host 'Issue #324: native autosave preview. This isolated fixture starts with 10 active seconds remaining.'
Write-Host 'Pause, menus and console do not advance the timer. Normal gameplay uses 300 active seconds after each autosave.'
Write-Host 'After Game saved, open Load Game and load the latest preview autosave; check your bag and the released follower.'
Write-Host 'Close GZDoom when finished. This terminal remains open for your report.'
& powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5422/run_native.ps1 `
    -Directory $Directory -Label author-preview -Script manual.cfg -Interactive
if ($LASTEXITCODE -ne 0) { throw 'Preview runner failed; inspect the preserved native log.' }
