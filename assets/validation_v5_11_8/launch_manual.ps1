param([string]$Start = '')
$ErrorActionPreference = 'Stop'
$Host.UI.RawUI.WindowTitle = 'Caelum Argenteum 5.11.8 - Inmunidad y velocidades'
Set-Location -LiteralPath (Resolve-Path (Join-Path $PSScriptRoot '../..'))
$env:PYTHONIOENCODING = 'utf-8'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
if ($Start) { python (Join-Path $PSScriptRoot 'manual.py') --start $Start }
else { python (Join-Path $PSScriptRoot 'manual.py') }
