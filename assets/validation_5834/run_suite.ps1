param([string]$Runtime='final34a',[string]$Prefix='release')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Push-Location $repo
try {
 python assets/validation_5834/prepare.py
 if($LASTEXITCODE-ne0){throw 'Diagnostic preparation failed'}
 foreach($case in @('catalogue','craft','trade','items','placement','seed','resume','hub','legacy','view0','view1','view2','view3','use','oldresume')) {
  $map=if($case-in@('catalogue','craft','trade','items','view0','view1','view2','view3')){'CSUP410'}else{'MAP01'}
  $taskArguments=@('-NoProfile','-ExecutionPolicy','Bypass','-File','assets/validation_5834/run_native.ps1','-Runtime',$Runtime,'-Label',($Prefix+'-'+$case),'-Checks','-Script',$case,'-StartMap',$map)
  if($case-eq'resume'){$taskArguments+=@('-LoadGame','rest-furniture.zds')}
  if($case-eq'oldresume'){$taskArguments+=@('-LoadGame','prior-rest-supply.zds')}
  if($case-eq'legacy'){$taskArguments+=@('-LoadGame','reading-progress.zds')}
  if($case-in@('view0','view1','view2','view3')){$taskArguments+=@('-Language','es')}
  & powershell @taskArguments
  if($LASTEXITCODE-ne0){throw "Native check failed: $case"}
 }
} finally {Pop-Location}
