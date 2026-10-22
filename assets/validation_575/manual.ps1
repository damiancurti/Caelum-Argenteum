param([string]$Label=('author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference='Stop'
$Host.UI.RawUI.WindowTitle='Caelum Argenteum - Prueba #407'
Clear-Host
Write-Host 'PRUEBA #407 - CACHIYUYO Y YODO' -ForegroundColor Cyan
Write-Host ''
Write-Host 'No escribas comandos aqui. Las teclas siguientes se usan DENTRO DEL JUEGO.'
Write-Host 'La sala de prueba entrega 1 kg de cachiyuyo y la receta de yodo ya aprendida.'
Write-Host '1. Pulsa E frente al banco: aparece Yodo. A 100%, el lote consume 100 g y entrega 1 g.'
Write-Host '2. Inicia la fabricacion desde el menu. Puedes esperar o pulsar F5 para adelantar trabajo.'
Write-Host '3. Comprueba que disminuye el cachiyuyo y recibes yodo una sola vez.'
Write-Host '4. F1 abre Provisiones: compra cachiyuyo y comprueba el descuento de dinero y existencias.'
Write-Host '5. F2 vuelve al banco conectado con Alquimia. Q cierra los paneles.'
Write-Host '6. Camina con WASD y mira los dos objetos del suelo: ambos deben ser modelos 3D.'
Write-Host '7. F3 guarda y F4 carga: deben conservarse materiales, dinero y existencias. F2 debe seguir funcionando.'
Write-Host 'Opcional: el lote minimo al 25/50% debe pedir aumentar el lote o la eficiencia, sin gastar materiales.'
Write-Host ''
Write-Host 'F5 es solo una ayuda temporal de esta prueba. Cierra el juego al terminar y comunica el resultado.'
& (Join-Path $PSScriptRoot 'run_native.ps1') -Label $Label -Checks -Script interactive -Interactive
