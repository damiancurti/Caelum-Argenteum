param([string]$Runtime='final30c',[string]$Prefix='release')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Push-Location $repo
try {
    python assets/validation_5830/prepare.py
    if($LASTEXITCODE-ne0){throw 'Diagnostic preparation failed'}
    foreach($test in @('core','input','seed','resume','hub','migration','transactions','view0','view1','view2','view3','view4','view5','spanish')) {
        $taskArguments=@('-NoProfile','-ExecutionPolicy','Bypass','-File','assets/validation_5830/run_native.ps1',
            '-Runtime',$Runtime,'-Label',($Prefix+'-'+$test),'-Checks','-Script',$test)
        if($test-eq'resume'){$taskArguments+=@('-LoadGame','luxury.zds')}
        if($test-eq'migration'){$taskArguments+=@('-LoadGame','reading-progress.zds')}
        if($test-eq'spanish'){$taskArguments+=@('-Language','es')}
        & powershell @taskArguments
        if($LASTEXITCODE-ne0){throw "Native check failed: $test"}
    }
} finally {Pop-Location}
