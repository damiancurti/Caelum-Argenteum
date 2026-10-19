param([string]$Directory='issue312-final02',[switch]$CeilingOnly,[switch]$LegacyCeilingOnly)
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot '..\validation_552\run_native.ps1'
function Invoke-PressureRun([string]$Label,[string]$Fixture,[string]$Script,[string]$Map='MAPQA',[string]$LoadGame='',[string]$Runtime='production.pk3') {
    & $runner -Directory $Directory -Label $Label -Fixture $Fixture -Script $Script -Map $Map -LoadGame $LoadGame -Runtime $Runtime
}
if($LegacyCeilingOnly) {
    Invoke-PressureRun 'ceiling-old-upgrade' 'ceilingsave.pk3' 'old-ceiling-load.cfg' 'MAPQA' 'original-ceiling.zds'
    Invoke-PressureRun 'ceiling-original-rollback' 'ceilingsave.pk3' 'rollback.cfg' 'MAPQA' 'original-ceiling.zds' 'original.pk3'
    Invoke-PressureRun 'ceiling-upgraded-rollback' 'ceilingsave.pk3' 'rollback.cfg' 'MAPQA' 'ca312-legacy-converted.zds' 'original.pk3'
    return
}
if(!$CeilingOnly) {
    Invoke-PressureRun 'probe' 'probe.pk3' 'probe.cfg'
    Invoke-PressureRun 'flow' 'flow.pk3' 'flow.cfg'
    Invoke-PressureRun 'combat' 'combat.pk3' 'combat.cfg'
    Invoke-PressureRun 'motion' 'motion.pk3' 'motion.cfg'
}
Invoke-PressureRun 'pressure' 'pressure.pk3' 'pressure.cfg' 'THAZARD'
Invoke-PressureRun 'ceiling-pause' 'ceiling.pk3' 'ceiling.cfg'
if(!$CeilingOnly) {
    Invoke-PressureRun 'hub' 'travel.pk3' 'travel.cfg'
    Invoke-PressureRun 'current-save' 'persist.pk3' 'save.cfg'
    Invoke-PressureRun 'current-load' 'persist.pk3' 'load.cfg' 'MAPQA' 'ca312-ongoing.zds'
    Invoke-PressureRun 'old-upgrade' 'persist.pk3' 'old-load.cfg' 'MAPQA' 'original-ongoing.zds'
}
Invoke-PressureRun 'ceiling-save' 'ceilingsave.pk3' 'ceiling-save.cfg'
Invoke-PressureRun 'ceiling-load' 'ceilingsave.pk3' 'ceiling-load.cfg' 'MAPQA' 'ca312-ceiling.zds'
if(!$CeilingOnly) {
    Invoke-PressureRun 'original-rollback' 'persist.pk3' 'rollback.cfg' 'MAPQA' 'original-ongoing.zds' 'original.pk3'
    Invoke-PressureRun 'current-rollback' 'persist.pk3' 'rollback.cfg' 'MAPQA' 'ca312-ongoing.zds' 'original.pk3'
}
