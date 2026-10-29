param([string]$Runtime='final29d',[string]$Prefix='delivery')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Push-Location $repo
try {
    python assets/validation_5829/prepare.py
    if($LASTEXITCODE-ne0){throw 'Diagnostic preparation failed'}
    foreach($test in @('core','input','lifecycle','seed','resume','hub','migration','view0-0','view0-1','view1-0','view1-1','view1-2')) {
        $taskArguments=@('-NoProfile','-ExecutionPolicy','Bypass','-File','assets/validation_5829/run_native.ps1',
            '-Runtime',$Runtime,'-Label',($Prefix+'-'+$test),'-Checks','-Script',$test)
        if($test-eq'resume'){$taskArguments+=@('-LoadGame','sofa-seat.zds')}
        if($test-eq'migration'){$taskArguments+=@('-LoadGame','reading-progress.zds')}
        & powershell @taskArguments
        if($LASTEXITCODE-ne0){throw "Native check failed: $test"}
    }
} finally {Pop-Location}
