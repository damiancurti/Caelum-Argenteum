param([string]$Config = 'build/issue469-terminal02/session-config.json')
$ErrorActionPreference = 'Stop'
$ProjectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
Set-Location -LiteralPath $ProjectRoot
$Host.UI.RawUI.WindowTitle = 'Caelum Argenteum 5.18.3 - Revision completa'
python -X utf8 (Join-Path $ProjectRoot 'assets/validation_v5_17_123/author_terminal.py') --config $Config
if ($LASTEXITCODE -ne 0) { Write-Host 'Terminal error. Existing saves and author observations have been preserved.' }
