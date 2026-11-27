param(
    [string]$Package = (Join-Path $PSScriptRoot 'caelum_argenteum.ipk3'),
    [string]$Engine = 'C:/Program Files (x86)/GZDoom/gzdoom.exe',
    [string]$ProfileDirectory = '',
    [string]$LoadSave = ''
)
$ErrorActionPreference = 'Stop'
$EnginePath = (Resolve-Path -LiteralPath $Engine).Path
$PackagePath = (Resolve-Path -LiteralPath $Package).Path
if ([IO.Path]::GetExtension($PackagePath) -ne '.ipk3') {
    throw 'Select the independent caelum_argenteum.ipk3 package.'
}
$Version = [Diagnostics.FileVersionInfo]::GetVersionInfo($EnginePath).FileVersion
if ($Version -notmatch '^g?4\.14\.2(?:\D|$)') {
    throw "GZDoom 4.14.2 is required. Selected engine reports '$Version'. Install it separately and pass -Engine with its path."
}
if (-not $ProfileDirectory) {
    $ManifestPath = Join-Path ([IO.Path]::GetDirectoryName($PackagePath)) 'MANIFEST.json'
    $Variant = 'current'
    if (Test-Path -LiteralPath $ManifestPath) {
        $Manifest = Get-Content -LiteralPath $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($Manifest.variant -in @('legacy-map02-r5', 'legacy-map03-r3', 'legacy-map02-r5-map03-r3')) { $Variant = $Manifest.variant }
    }
    $ProfileDirectory = Join-Path (Join-Path $env:LOCALAPPDATA 'CaelumArgenteum') $Variant
}
$ProfilePath = [IO.Path]::GetFullPath($ProfileDirectory)
[IO.Directory]::CreateDirectory($ProfilePath) | Out-Null
$ConfigPath = Join-Path $ProfilePath 'gzdoom.ini'
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    $InitialConfig = "[GlobalSettings]`nvid_fullscreen=false`nvid_activeinbackground=true`ni_pauseinbackground=false`ni_soundinbackground=true`nsnd_mastervolume=0.05`n"
    [IO.File]::WriteAllText($ConfigPath, $InitialConfig, (New-Object Text.UTF8Encoding($false)))
}
$EngineArguments = @('-noautoload', '-iwad', $PackagePath, '-config', $ConfigPath,
    '-savedir', $ProfilePath, '+logfile', (Join-Path $ProfilePath 'latest.log'))
if ($LoadSave) {
    # GZDoom prefixes -savedir itself. Use only a verified leaf name here.
    if ([IO.Path]::GetFileName($LoadSave) -ne $LoadSave -or $LoadSave.Contains(':')) {
        throw 'LoadSave must be a filename inside ProfileDirectory, not an absolute or relative path.'
    }
    if (-not (Test-Path -LiteralPath (Join-Path $ProfilePath $LoadSave) -PathType Leaf)) {
        throw "Save not found in the selected profile: $LoadSave"
    }
    $EngineArguments += @('-loadgame', $LoadSave)
}
Write-Host 'Caelum Argenteum - independent review beta'
Write-Host "Profile and saves: $ProfilePath"
Push-Location -LiteralPath $ProfilePath
try {
    # A pipeline makes PowerShell wait for a native GUI application as well.
    & $EnginePath @EngineArguments | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "GZDoom exited with code $LASTEXITCODE. See latest.log in the profile directory." }
}
finally { Pop-Location }
