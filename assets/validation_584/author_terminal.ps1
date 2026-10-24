$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #496 - Musica de mapas'
$catalogue=Get-Content (Join-Path $repo 'assets/source/audio/map_music_496/catalogue.json') -Raw -Encoding UTF8 | ConvertFrom-Json
Write-Host 'CA496-MUSIC-01: escuchar las 19 pistas nuevas en GZDoom.'
Write-Host 'F1 siguiente; F2 anterior; F3 reiniciar la pista actual.'
Write-Host 'La consola muestra el numero y el nombre. El volumen inicial es 5%.'
Write-Host 'Revisa cortes inesperados, distorsion y transicion/repeticion al terminar.'
Write-Host 'Los destinos todavia no construidos quedan reservados. Las musicas anteriores siguen iguales.'
for($i=0;$i -lt $catalogue.tracks.Count;$i++){Write-Host ('{0,2}: {1}' -f ($i+1),$catalogue.tracks[$i].title)}
while($true){
    $choice=Read-Host '1 abre la sala de escucha; Q deja esta terminal abierta'
    if($choice -eq 'q'){break}
    if($choice -ne '1'){continue}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero la otra ventana de GZDoom.';continue}
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Label ('author-'+[DateTime]::Now.ToString('yyyyMMdd-HHmmss')) -Script interactive -Checks -Interactive
}
