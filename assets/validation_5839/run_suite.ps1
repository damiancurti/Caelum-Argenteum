param([string]$Runtime='final39a',[string]$Prefix='releasea')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Push-Location $repo
try {
    if(!(Test-Path -LiteralPath "build/issue415-aim/$Runtime/caelum_argenteum_dev.pk3")) {throw 'Finish the runtime build before starting native validation.'}
    python assets/validation_5839/prepare.py
    if($LASTEXITCODE-ne0){throw 'Fixture preparation failed'}
    foreach($case in @('math','native','seed','load','hub','legacy','mixed')) {
        $nativeArgs=@('-NoProfile','-ExecutionPolicy','Bypass','-File','assets/validation_5839/run_native.ps1','-Runtime',$Runtime,'-Label',"$Prefix-$case",'-Script',$case,'-Checks')
        if($case-eq'load'){$nativeArgs+=@('-LoadGame','aim-current39.zds')}
        if($case-eq'legacy'){$nativeArgs+=@('-LoadGame','aim-prior38.zds','-Addon','bridge/prior-checks.pk3')}
        & powershell @nativeArgs
        if($LASTEXITCODE-ne0){throw "Native failure: $case"}
    }
} finally {Pop-Location}
