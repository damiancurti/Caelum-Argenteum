$ErrorActionPreference = 'Stop'
$Host.UI.RawUI.WindowTitle = 'Caelum Argenteum - Correcciones V5.11 - 5.11.7'
Set-Location -LiteralPath (Resolve-Path (Join-Path $PSScriptRoot '../..'))
$env:PYTHONIOENCODING = 'utf-8'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
python (Join-Path $PSScriptRoot 'manual.py')
