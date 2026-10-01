param([string]$Engine, [string]$Iwad)
$ErrorActionPreference = 'Stop'
try {
    if (-not $Engine) { $Engine = Read-Host 'Full path to GZDoom 4.14.2 gzdoom.exe' }
    if (-not $Iwad) { $Iwad = Read-Host 'Full path to your Doom II DOOM2.WAD' }
    $Engine = $Engine.Trim('"')
    $Iwad = $Iwad.Trim('"')
    if (-not (Test-Path -LiteralPath $Engine -PathType Leaf)) { throw 'GZDoom executable not found.' }
    if (-not (Test-Path -LiteralPath $Iwad -PathType Leaf)) { throw 'Doom II IWAD not found.' }
    $Package = Join-Path $PSScriptRoot 'caelum_argenteum_dev.pk3'
    if (-not (Test-Path -LiteralPath $Package -PathType Leaf)) { throw 'Extract the complete playtest ZIP before launching.' }
    $UserDirectory = Join-Path $PSScriptRoot 'user'
    $SaveDirectory = Join-Path $UserDirectory 'saves'
    [IO.Directory]::CreateDirectory($SaveDirectory) | Out-Null
    & $Engine -iwad $Iwad -file $Package -config (Join-Path $UserDirectory 'gzdoom.ini') -savedir $SaveDirectory -noautoload
    exit $LASTEXITCODE
} catch {
    Write-Error $_
    exit 1
}
