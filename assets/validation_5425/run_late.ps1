param([string]$StageLabel='stage-01',[string]$StageScript='run.cfg',[string]$ProbeLabel='probe-01',[string]$ProbeScript='run.cfg',[switch]$SkipStage)
$ErrorActionPreference='Stop'
if(!$SkipStage) {
    & "$PSScriptRoot\run_native.ps1" -Directory issue304-late-stage -Label $StageLabel -Runtime runtime.pk3 -Fixture observer.pk3 -Script $StageScript -Seed 116 -Uncapped
}
$saved=Join-Path $PSScriptRoot '..\..\build\issue304-late-stage\combat.zds'
foreach($variant in @('on','off')) {
    $destination=Join-Path $PSScriptRoot "..\..\build\issue304-late-$variant\combat.zds"
    if(!(Test-Path -LiteralPath $destination)){Copy-Item -LiteralPath $saved -Destination $destination}
    & "$PSScriptRoot\run_native.ps1" -Directory "issue304-late-$variant" -Label $ProbeLabel -Runtime runtime.pk3 -Fixture observer.pk3 -Script $ProbeScript -LoadGame combat.zds -Seed 116 -Uncapped
}
