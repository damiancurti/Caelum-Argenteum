param([string]$Runtime = '')
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repoRoot
$Host.UI.RawUI.WindowTitle = 'Caelum Argenteum V5.14 - Pruebas'
if (-not $Runtime) { $Runtime = Join-Path $repoRoot 'build/v514/issue446-final.pk3' }
if (-not (Test-Path -LiteralPath $Runtime)) {
    throw 'Build the V5.14 candidate package before opening the author scenes.'
}
python (Join-Path $PSScriptRoot 'author_terminal.py') --runtime $Runtime
