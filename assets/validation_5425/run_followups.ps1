param(
    [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$Directory,
    [ValidateSet('detailed','natural','captures')][string]$Group='detailed',
    [string]$Fixture='observer-v4.pk3'
)
$ErrorActionPreference='Stop'
$plans=@{
    detailed=@('deep-thermal-off','deep-target-3s','no-seal-scan','base','no-seal-scan','thermal-off')
    natural=@('base','thermal-off')
    captures=@('models','base')
}
$index=0
foreach($variant in $plans[$Group]) {
    $index++
    $script=if($Group -eq 'natural'){'long.cfg'}elseif($Group -eq 'captures'){'bench.cfg'}else{'study.cfg'}
    $runtime=if($Group -eq 'natural'){"natural-$variant.pk3"}else{"$variant.pk3"}
    & "$PSScriptRoot\run_native.ps1" -Directory $Directory -Label "$Group-$index-$variant" -Runtime $runtime -Fixture $Fixture -Script $script -Seed 116 -Uncapped
}
