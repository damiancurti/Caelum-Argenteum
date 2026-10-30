$ErrorActionPreference = 'Stop'
$project = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$output = Join-Path $project 'build/issue428/manual'
$package = Join-Path $project 'build/issue428/final/caelum_argenteum_dev.pk3'
$engine = 'C:/Program Files (x86)/GZDoom/gzdoom.exe'
$iwad = 'C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD'
$addon = Join-Path $output 'manual.pk3'
foreach ($file in @($package,$engine,$iwad,$addon)) {
    if (-not (Test-Path -LiteralPath $file)) { throw "Missing prerequisite: $file" }
}
Set-Location -LiteralPath $project
$utf8 = New-Object System.Text.UTF8Encoding($false)
while ($true) {
    Write-Host ''
    Write-Host 'CAELUM ARGENTEUM - V5.10' -ForegroundColor Cyan
    Write-Host '1 - #425 Vision y reconocimiento'
    Write-Host '2 - #426 Ruido anonimo y busqueda'
    Write-Host '3 - #427 Memoria de 30 segundos'
    Write-Host '4 - #428 Testigo, lider y orden audible'
    Write-Host '5 - Recorrer la ciudad normal (MAP03)'
    Write-Host '6 - Repetir comprobaciones automaticas por issue'
    Write-Host '0 - Salir'
    $choice = Read-Host 'Numero'
    if ($choice -eq '0') { break }
    if ($choice -eq '6') {
        $issueChoice = Read-Host 'Issue (425, 426, 427 o 428)'
        if ($issueChoice -notin @('425','426','427','428')) { continue }
        $waitTics = if ($issueChoice -eq '425') {240} elseif ($issueChoice -eq '426') {100} elseif ($issueChoice -eq '427') {1320} else {1140}
        $checks = Join-Path $project "build/issue$issueChoice/current/checks.pk3"
        if ($issueChoice -eq '425') { $checks = Join-Path $project 'build/issue428/integration/checks425.pk3' }
        $label = 'author-' + $issueChoice + '-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
        & python assets/validation_5103/run_native.py $label --full --package $package --checks $checks --map "CA$($issueChoice)A" --prefix "CA$issueChoice" --language es --commands "netevent ca$($issueChoice)_seed; wait $waitTics"
        Write-Host 'Resultado impreso arriba. Esta terminal permanece abierta.'
        continue
    }
    if ($choice -notin @('1','2','3','4','5')) { continue }
    if (Get-Process gzdoom -ErrorAction SilentlyContinue) {
        Write-Host 'Cierra primero la ventana anterior de GZDoom para conservar una sola prueba activa.'
        continue
    }
    $mode = [int]$choice
    Write-Host ''
    switch ($mode) {
        1 { Write-Host 'Veras al guardia reconocerte tras unos 2 segundos. F6 reinicia su percepcion mirando al otro lado; F5 te coloca visible. F7 oscurece/ilumina: en oscuridad no debe verte a esa distancia.' }
        2 { Write-Host 'En esta prueba sos invisible para la IA visual. F3 crea un ruido; el NPC debe ir a ese punto sin identificarte. F4 te traslada en silencio: no debe perseguir la nueva posicion. Usar F4 evita generar pasos al caminar.' }
        3 { Write-Host 'Deja que te reconozca. F4 te oculta: debe buscar el ultimo punto, no seguirte. F5 antes de 30 s permite reconocerte enseguida. Repite y espera a que recuerdos llegue a 0; entonces F5 debe requerir otros 2 s.' }
        4 { Write-Host 'El testigo ve al objetivo, avisa al lider y este ordena al receptor. Mira recuerdos y orden en el panel. F4 aleja al receptor y borra solo su evidencia del laboratorio: no debe recibir orden. F5 lo acerca; debe recibirla en un maximo de 5 s. Oir otros ruidos puede subir alerta sin identificar.' }
        5 { Write-Host 'Recorre la ciudad y mira tambien hacia el suelo. Comprueba fluidez y ausencia de errores. Esta opcion usa la campana normal.' }
    }
    Write-Host 'F2 imprime detalles en la consola del juego. F1 reinicia el laboratorio. Cierra GZDoom para elegir otro escenario aqui.'
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $ini = Join-Path $output "author-$stamp.ini"
    $cfg = Join-Path $output "author-$stamp.cfg"
    $log = Join-Path $output "author-$stamp.log"
    [IO.File]::WriteAllText($ini,"[LastRun]`nVersion=225`n[GlobalSettings]`nvid_preferbackend=1`nvid_vsync=true`nvid_maxfps=60`ncl_capfps=false`nvid_activeinbackground=true`ni_pauseinbackground=false`nvid_lowerinbackground=false`ni_soundinbackground=true`nsnd_mastervolume=0.05`nvid_fullscreen=false`nlanguage=es`n",$utf8)
    $commands = if ($mode -eq 5) {'wait 80'} else {
        "con_notifytime 0`nbind f1 `"map CA510L; wait 80; netevent ca510_mode $mode`"`n" +
        'bind f2 "netevent ca510_report"' + "`n" +
        'bind f3 "netevent ca510_noise"' + "`n" +
        'bind f4 "netevent ca510_hide"' + "`n" +
        'bind f5 "netevent ca510_return"' + "`n" +
        'bind f6 "netevent ca510_turn"' + "`n" +
        'bind f7 "netevent ca510_light"' + "`nwait 80; netevent ca510_mode $mode"
    }
    [IO.File]::WriteAllText($cfg,$commands+"`n",$utf8)
    $map = if ($mode -eq 5) {'MAP03'} else {'CA510L'}
    $files = if ($mode -eq 5) {@($package)} else {@($package,$addon)}
    & $engine -noautoload -iwad $iwad -file @files -config $ini -savedir $output -window -width 1280 -height 720 -rngseed 428 +logfile $log +map $map +exec $cfg
    Write-Host "Registro: $log"
}
