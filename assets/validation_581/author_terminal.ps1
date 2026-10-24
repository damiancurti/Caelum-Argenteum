$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #413 - Altitud y aclimatacion (5.8.1)'
Write-Host '#413 / 5.8.1 - prueba privada de altitud'
Write-Host '1: iniciar una sala nueva; 2: cargar un guardado privado; Q: dejar abierta esta terminal.'
Write-Host 'F1: nivel del mar. F2: 2000 m. F3: 4000 m.'
Write-Host 'F4: avanzar cinco dias de exposicion. F5: gastar 100 puntos base de Aire.'
Write-Host 'F6: informe en consola. F7: alternar humano/Caelith.'
Write-Host 'Cierra la consola para moverte y observar la recuperacion; Escape para guardar/cargar.'
Write-Host 'Comprueba que el coste aumenta con la altitud, baja con adaptacion y es menor para Caelith.'
Write-Host 'Al volver al nivel del mar los factores deben ser 1. Guardar/cargar conserva la adaptacion.'
Write-Host 'F4 y los cambios de raza son controles exclusivos de esta prueba; no uses partidas de campana aqui.'
while($true){
    $choice=Read-Host 'Elige 1, 2 o Q'
    if($choice -eq 'q'){break}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero la partida de GZDoom abierta.';continue}
    if($choice -notin @('1','2')){continue}
    $options=@{Label=('author-'+[DateTime]::Now.ToString('yyyyMMdd-HHmmss'));Checks=$true;Interactive=$true;Script='interactive'}
    if($choice -eq '2'){
        $name=Read-Host 'Nombre .zds dentro de build/issue413'
        if([IO.Path]::GetFileName($name) -ne $name -or !$name.EndsWith('.zds') -or !(Test-Path -LiteralPath (Join-Path $repo "build/issue413/$name"))){Write-Host 'Elige un guardado privado existente.';continue}
        $options.LoadGame=$name;$options.Script='resume'
    }
    & (Join-Path $PSScriptRoot 'run_native.ps1') @options
}
