$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$host.UI.RawUI.WindowTitle='Caelum 5.8.56 - Correcciones'
$taskRunner=Join-Path $taskRoot 'assets/validation_5853/run_native.ps1'
$taskOptions=@(
 @{Name='410 - Cantimplora y botella: llenar con Usar';Map='MAP01';Addon='review410-manual.pk3';Script='manual56-water';Steps='Estas frente a la fuente con cantimplora vacia seleccionada. Enter la llena; [ y ] cambian el objeto. I y R conservan el llenado anterior. Apunta lejos de la fuente para beber si tienes sed.'},
 @{Name='410 - Camas, colchones, almohadas y dosel';Map='CRVW410';Addon='review410-manual.pk3';Script='manual56-beds';Steps='Observa ambas camas desde cerca. La comun tiene colchon y almohada; la de lujo tiene dos almohadas y dosel. E permite usarlas.'},
 @{Name='410 - Cuadro pequeno, cuadro grande y estatua';Map='CRVW410';Addon='review410-manual.pk3';Script='manual56-art';Steps='Los tres objetos estan juntos delante. Acercate a la estatua para ver sus detalles. El cuadro pequeno conserva su diseno; el grande mide 2,16 x 1,56 m.'},
 @{Name='410 - Colocar y recoger el cuadro grande';Map='MAP01';Addon='review410-manual.pk3';Script='manual56-large';Steps='El cuadro esta colocado en una pared real. Agachate y pulsa E para recogerlo. Desde I puedes colocarlo otra vez; necesita una pared libre y suficientemente grande.'},
 @{Name='415 - Caminar en la ciudad y comprobar fluidez';Map='MAP01';Addon='author-5851.pk3';Script='author-5851';Steps='Espera a que termine la llegada a la ciudad. Camina durante un minuto y mira hacia los defensores. No deberia aparecer la caida a cuadros de casi un segundo. Los NPC conservan sus funciones.'},
 @{Name='416 - Buenos Aires con Ciudad';Map='CABAIRES';Addon='author-5852.pk3';Script='author-5852';Steps='Escucha el tema Ciudad, de la primera coleccion. Audio inicial al 5%; puedes subirlo desde Opciones. Los otros viajes ya estan aceptados.'}
)
Write-Host 'CAELUM ARGENTEUM 5.8.56 - CORRECCIONES PENDIENTES' -ForegroundColor Cyan
Write-Host 'Partidas privadas. E: interactuar; Enter: usar objeto seleccionado; I: inventario.'
Write-Host 'Solo hay que revisar estas correcciones. Cierra GZDoom antes de elegir otra.'
while($true){
 for($i=0;$i -lt $taskOptions.Count;$i++){Write-Host ("{0}. {1}" -f ($i+1),$taskOptions[$i].Name)}
 $taskChoice=Read-Host 'Numero de escenario (Q salir)'
 if($taskChoice -eq 'q'){break}
 $taskIndex=0
 if(![int]::TryParse($taskChoice,[ref]$taskIndex) -or $taskIndex -lt 1 -or $taskIndex -gt $taskOptions.Count){continue}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero el juego.' -ForegroundColor Yellow;continue}
 $taskCase=$taskOptions[$taskIndex-1]
 Write-Host $taskCase.Steps -ForegroundColor Cyan
 & $taskRunner -Label ('author56-'+$taskIndex+'-'+(Get-Date -Format 'yyyyMMdd-HHmmss')) -Runtime review56 -Checks -Addon $taskCase.Addon -Script $taskCase.Script -StartMap $taskCase.Map -Language es -Interactive
}
