# GZDoom 4.14.2 reads bots.cfg only beside the executable on Windows.
# Use a local copy of the already-installed engine; never modify the installation.
param([string]$Installed = 'C:\Program Files (x86)\GZDoom')
$ErrorActionPreference = 'Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$destination=Join-Path $repo 'build\issue120\engine'
New-Item -ItemType Directory -Force $destination,(Join-Path $destination 'zcajun') | Out-Null
foreach($name in @('gzdoom.exe','gzdoom.pk3','game_support.pk3','game_widescreen_gfx.pk3','brightmaps.pk3','lights.pk3','openal32.dll','sndfile.dll','zmusic.dll','licenses.zip')){
    Copy-Item -LiteralPath (Join-Path $Installed $name) -Destination (Join-Path $destination $name)
}
[IO.File]::WriteAllText((Join-Path $destination 'zcajun\bots.cfg'),"{ name AuthorityPeer aiming 0 perfection 0 reaction 0 isp 0 }`n")
if((Get-FileHash -LiteralPath (Join-Path $Installed 'gzdoom.exe')).Hash -ne (Get-FileHash -LiteralPath (Join-Path $destination 'gzdoom.exe')).Hash){throw 'Engine copy differs from installed engine'}
Write-Output 'Prepared identical local engine with one isolated native bot definition.'
