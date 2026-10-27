param([string]$Runtime='final32a',[string]$Prefix='release')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Push-Location $repo
try {
 python assets/validation_5832/prepare.py
 if($LASTEXITCODE-ne0){throw 'Diagnostic preparation failed'}
 foreach($case in @('catalogue','craft','trade','items','placement','seed','resume','hub','legacy','view0','view1','use')) {
  $map=if($case-in@('catalogue','craft','trade','items','view0','view1')){'CSUP410'}else{'MAP01'}
  $taskArguments=@('-NoProfile','-ExecutionPolicy','Bypass','-File','assets/validation_5832/run_native.ps1','-Runtime',$Runtime,'-Label',($Prefix+'-'+$case),'-Checks','-Script',$case,'-StartMap',$map)
  if($case-eq'resume'){$taskArguments+=@('-LoadGame','rest-furniture.zds')}
  if($case-eq'legacy'){$taskArguments+=@('-LoadGame','reading-progress.zds')}
  if($case-in@('view0','view1')){$taskArguments+=@('-Language','es')}
  & powershell @taskArguments
  if($LASTEXITCODE-ne0){throw "Native check failed: $case"}
 }
} finally {Pop-Location}
