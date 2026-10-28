param([string]$Runtime='final38a',[string]$Prefix='releaseb')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Push-Location $repo
try {
    if(!(Test-Path -LiteralPath "build/issue502-npc-illness/$Runtime/caelum_argenteum_dev.pk3")) {throw 'Finish the runtime build before starting native validation.'}
    python assets/validation_5838/prepare.py
    if($LASTEXITCODE-ne0){throw 'Fixture preparation failed'}
    foreach($case in @('core','recovery','exposure','seed','load','hub','legacy','live','clock','perf')) {
        $nativeArgs=@('-NoProfile','-ExecutionPolicy','Bypass','-File','assets/validation_5838/run_native.ps1','-Runtime',$Runtime,'-Label',"$Prefix-$case",'-Script',$case,'-Checks')
        if($case-eq'load'){$nativeArgs+=@('-LoadGame','npc-current38.zds')}
        if($case-eq'legacy'){$nativeArgs+=@('-LoadGame','npc-prior37.zds','-Addon','bridge/prior-checks.pk3')}
        & powershell @nativeArgs
        if($LASTEXITCODE-ne0){throw "Native failure: $case"}
    }
} finally {Pop-Location}
