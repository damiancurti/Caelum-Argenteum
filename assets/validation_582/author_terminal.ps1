$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #414 - Depositos de la mansion (5.8.2)'
Write-Host '#414 / 5.8.2 - CA414-01'
Write-Host '1: nueva prueba de mansion; 2: cargar tu guardado de esta prueba; Q: dejar la terminal abierta.'
Write-Host 'Usa la tecla de Usar mirando la palanca. El panel superior indica abrir/cerrar.'
Write-Host 'F1: volver al camino. F2/F3: entrar al deposito norte/sur. F4: avanzar un minuto del mundo.'
Write-Host 'F5: informe de litros/niveles en consola. F6: vista elevada. F1 vuelve a caminar.'
Write-Host 'Comprueba: niveles iniciales 1,75 m y 0,25 m; abrir trasvasa agua; cerrar permite recuperarlos.'
Write-Host 'Recorre ambos depositos y sal por los peldanos. No hace falta saltar para subirlos.'
Write-Host 'La botella de 1 L comienza vacia: sumergirla en agua potable la llena y descuenta ese litro.'
Write-Host 'Guarda/carga con Escape con la compuerta abierta y cerrada: no deben reiniciarse niveles.'
Write-Host 'La piscina anterior debe seguir funcionando. Esta prueba usa guardados separados de tu campana.'
Write-Host 'F2/F3/F4/F6 y la invulnerabilidad son ayudas privadas de prueba; no forman parte del juego.'
while($true){
    $choice=Read-Host 'Elige 1, 2 o Q'
    if($choice -eq 'q'){break}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
    if($choice -notin @('1','2')){continue}
    $options=@{Label=('author-'+[DateTime]::Now.ToString('yyyyMMdd-HHmmss'));Checks=$true;Interactive=$true;Script='interactive';StartMap='MAP01'}
    if($choice -eq '2'){
        $name=Read-Host 'Nombre .zds de tu prueba 5.8.2 dentro de build/issue414-runtime'
        if([IO.Path]::GetFileName($name) -ne $name -or !$name.EndsWith('.zds') -or !(Test-Path -LiteralPath (Join-Path $repo "build/issue414-runtime/$name"))){Write-Host 'Elige un guardado privado existente.';continue}
        $options.LoadGame=$name;$options.Script='resume'
    }
    & (Join-Path $PSScriptRoot 'run_native.ps1') @options
}
