param([string]$Runtime='final33b',[string]$Prefix='release')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Push-Location $repo
try {
 python assets/validation_5833/prepare.py
 if($LASTEXITCODE-ne0){throw 'Diagnostic preparation failed'}
 foreach($case in @('core','seed','resume','hub','legacyresume','migration','view0','view1','side3','side4','side5','input0','input1')) {
  $taskArgs=@('-NoProfile','-ExecutionPolicy','Bypass','-File','assets/validation_5833/run_native.ps1','-Runtime',$Runtime,'-Label',($Prefix+'-'+$case),'-Script',$case,'-Checks')
  if($case-eq'resume'){$taskArgs+=@('-LoadGame','basic-rest.zds')}
  if($case-eq'legacyresume'){$taskArgs+=@('-LoadGame','basic-old.zds')}
  if($case-eq'migration'){$taskArgs+=@('-LoadGame','reading-progress.zds','-StartMap','MAP01')}
  if($case-like'side*' -or $case-like'view*'){$taskArgs+=@('-Language','es')}
  & powershell @taskArgs
  if($LASTEXITCODE-ne0){throw "Native case failed: $case"}
 }
} finally {Pop-Location}
