$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #410 - Contaminacion y HUD (primera etapa)'
Write-Host 'CA410-CORE-01 / #410: primera etapa, enfermedad y HUD.'
Write-Host 'Los lotes de comida, recetas y muebles siguen en implementacion.'
Write-Host '1 inicia una sala privada; 2 carga un guardado de esta sala; Q deja la terminal abierta.'
Write-Host 'F5 abre Personaje: revisa la barra/icono de Contaminacion y que no tape Exposicion.'
Write-Host 'F1: 1.000 de Vida, contaminacion 60, Dureza 0, sin regeneracion. Pierde 10 Vida/s.'
Write-Host 'F2: Dureza 100. El dano debe detenerse; la contaminacion se conserva.'
Write-Host 'F3: Vida llena y contaminacion 0,5; acelera SOLO la regeneracion de prueba.'
Write-Host 'Debe limpiar ese medio grado en un segundo pagando Hambre/Hidratacion, sin superar Vida maxima.'
Write-Host 'F4 imprime valores en consola. Escape permite guardar/cargar; F5 revisa el estado.'
Write-Host 'Los valores y atajos anteriores son ayudas privadas; no alteran tu campana.'
while($true){
    $choice=Read-Host 'Elige 1, 2 o Q'
    if($choice -eq 'q'){break}
    if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
    if($choice -notin @('1','2')){continue}
    $options=@{Label=('author-'+[DateTime]::Now.ToString('yyyyMMdd-HHmmss'));Checks=$true;Interactive=$true;Script='interactive';StartMap='CAF410'}
    if($choice -eq '2'){
        $name=Read-Host 'Nombre .zds de esta prueba dentro de build/issue410'
        if([IO.Path]::GetFileName($name) -ne $name -or !$name.EndsWith('.zds') -or !(Test-Path -LiteralPath (Join-Path $repo "build/issue410/$name"))){Write-Host 'Elige un guardado privado existente.';continue}
        $options.LoadGame=$name;$options.Script='resume'
    }
    & (Join-Path $PSScriptRoot 'run_native.ps1') @options
}
