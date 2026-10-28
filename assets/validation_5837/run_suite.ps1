param([string]$Runtime='final37a',[string]$Prefix='releasea')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Push-Location $repo
try {
    python assets/validation_5837/prepare.py
    if($LASTEXITCODE-ne0){throw 'Fixture preparation failed'}
    foreach($case in @('core','weather','seed','load','hub','legacy','rainseed','rainload','perf')) {
        $nativeArgs=@('-NoProfile','-ExecutionPolicy','Bypass','-File','assets/validation_5837/run_native.ps1','-Runtime',$Runtime,'-Label',"$Prefix-$case",'-Script',$case,'-Checks')
        if($case-eq'load'){$nativeArgs+=@('-LoadGame','seal-current37.zds')}
        if($case-eq'legacy'){$nativeArgs+=@('-LoadGame','seal-prior36.zds','-Addon','bridge/prior-checks.pk3')}
        if($case-eq'rainload'){$nativeArgs+=@('-LoadGame','seal-rain37.zds')}
        & powershell @nativeArgs
        if($LASTEXITCODE-ne0){throw "Native failure: $case"}
    }
} finally {Pop-Location}
