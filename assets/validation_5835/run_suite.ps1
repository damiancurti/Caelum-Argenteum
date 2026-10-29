param([string]$Runtime='final35a',[string]$Prefix='release')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Push-Location $repo
try {
 python assets/validation_5835/prepare.py
 if($LASTEXITCODE-ne0){throw 'Diagnostic preparation failed'}
 foreach($case in @('catalogue','craft','trade','items','placement','seed','resume','hub','legacy','sofaplace','sofaseed','sofaresume','sofahub','sofaupgrade','view4','view5','sofainput')) {
  $map=if($case-in@('catalogue','craft','trade','items','view0','view1','view2','view3','view4','view5')){'CSUP410'}else{'MAP01'}
  $taskArguments=@('-NoProfile','-ExecutionPolicy','Bypass','-File','assets/validation_5835/run_native.ps1','-Runtime',$Runtime,'-Label',($Prefix+'-'+$case),'-Checks','-Script',$case,'-StartMap',$map)
  if($case-eq'resume'){$taskArguments+=@('-LoadGame','rest-furniture.zds')}
  if($case-eq'sofaresume'){$taskArguments+=@('-LoadGame','sofa-supply.zds')}
  if($case-eq'sofaupgrade'){$taskArguments+=@('-LoadGame','sofa-prior.zds')}
  if($case-eq'legacy'){$taskArguments+=@('-LoadGame','reading-progress.zds')}
  if($case-in@('view0','view1','view2','view3','view4','view5')){$taskArguments+=@('-Language','es')}
  & powershell @taskArguments
  if($LASTEXITCODE-ne0){throw "Native check failed: $case"}
 }
} finally {Pop-Location}
