$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
$Host.UI.RawUI.WindowTitle='Caelum #502 - Enfermedad desde 90'
Write-Host 'CA502-SEVERE-01. Sala privada; no modifica tus partidas de campana.'
Write-Host 'Si aparece el dialogo inicial, cerralo con Escape. Abri el HUD de supervivencia habitual.'
Write-Host 'F1: contaminacion 89. F2: 90. F3: 100. Cada tecla restaura la Vida de prueba.'
Write-Host 'Con 90 debe decir Enfermo y el dano por segundo debe ser aproximadamente el doble que con 89.'
Write-Host 'F4: 90 con Dureza 100; debe indicar Enfermo e inmunidad, sin perder Vida.'
Write-Host 'F5: limpiar y restaurar para continuar. Evita quedarte varios segundos con F2/F3: puede matar.'
Write-Host 'Esta prueba cubre enfermedad/etiqueta. Contactos, jabon y banos siguen en implementacion.'
while($true){
 $choice=Read-Host '1 sala manual; 2 checks nativos; Q deja la terminal abierta'
 if($choice -eq 'q'){break}
 if(Get-Process gzdoom -ErrorAction SilentlyContinue){Write-Host 'Cierra primero GZDoom.';continue}
 python (Join-Path $PSScriptRoot 'prepare.py')
 if($LASTEXITCODE -ne 0){throw 'Could not prepare private fixture.'}
 $stamp=[DateTime]::Now.ToString('yyyyMMdd-HHmmss')
 if($choice -eq '1'){
  & (Join-Path $PSScriptRoot 'run_native.ps1') -Runtime final-reviewed -Label ('author-severe-'+$stamp) -Checks -Addon checks.pk3 -Interactive -Script manual -Language es
 } elseif($choice -eq '2'){
  foreach($check in @('rules','runtime')){
   & (Join-Path $PSScriptRoot 'run_native.ps1') -Runtime final-reviewed -Label ('author-severe-'+$check+'-'+$stamp) -Checks -Addon checks.pk3 -Script $check
  }
 }
}
