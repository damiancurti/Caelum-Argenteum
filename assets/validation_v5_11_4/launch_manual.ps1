$ErrorActionPreference = 'Stop'
$Host.UI.RawUI.WindowTitle = 'Caelum Argenteum - Pruebas V5.11'
Set-Location -LiteralPath (Resolve-Path (Join-Path $PSScriptRoot '../..'))
$env:PYTHONIOENCODING = 'utf-8'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
python (Join-Path $PSScriptRoot 'manual.py')
