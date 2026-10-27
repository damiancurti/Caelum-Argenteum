param([string]$Runtime='final31b',[string]$Prefix='recheck')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Push-Location $repo
try {
 python assets/validation_5831/prepare.py
 if($LASTEXITCODE-ne0){throw 'Diagnostic preparation failed'}
 foreach($case in @('catalogue','craft','trade','items','placement','seed','resume','hub','legacy','inventory','shop')) {
  $map=if($case-in@('catalogue','craft','trade','items','inventory','shop')){'CSUP410'}else{'MAP01'}
  $taskArguments=@('-NoProfile','-ExecutionPolicy','Bypass','-File','assets/validation_5831/run_native.ps1','-Runtime',$Runtime,'-Label',($Prefix+'-'+$case),'-Checks','-Script',$case,'-StartMap',$map)
  if($case-eq'resume'){$taskArguments+=@('-LoadGame','storage-furniture.zds')}
  if($case-eq'legacy'){$taskArguments+=@('-LoadGame','reading-progress.zds')}
  if($case-in@('inventory','shop')){$taskArguments+=@('-Language','es')}
  & powershell @taskArguments
  if($LASTEXITCODE-ne0){throw "Native check failed: $case"}
 }
} finally {Pop-Location}
