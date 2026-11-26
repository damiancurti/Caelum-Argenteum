param([string]$Config = "build/issue889-release02/session-config.json")
$ErrorActionPreference = "Stop"
$ProjectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../.."))
Set-Location -LiteralPath $ProjectRoot
$Host.UI.RawUI.WindowTitle = "Caelum Argenteum - Revision consolidada"
python -X utf8 (Join-Path $PSScriptRoot "author_terminal.py") --config $Config
if ($LASTEXITCODE -ne 0) { Write-Host "Terminal error. Existing saves have been preserved." }
