param([string]$Directory='issue305-study-01',[ValidateSet('early','late','late-profile','profile','budget')][string]$Group='early')
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot '..\validation_5425\run_native.ps1'
$plans=@{early=@('base','registry','registry','base');late=@('base','registry','registry','base');'late-profile'=@('profile-base','profile-registry');profile=@('profile-base','profile-registry');budget=@('registry')}
$index=0
foreach($variant in $plans[$Group]) {
    $index++
    if($Group -in @('late','late-profile')) {
        & $runner -Directory "$Directory-late-$variant" -Label "$Group-$index-$variant" -Runtime runtime.pk3 -Fixture observer.pk3 -Script late.cfg -LoadGame combat.zds -Seed 116 -Uncapped
    } else {
        $script=if($Group -eq 'budget'){'budget.cfg'}else{'study.cfg'}
        & $runner -Directory $Directory -Label "$Group-$index-$variant" -Runtime "$variant.pk3" -Fixture observer.pk3 -Script $script -Seed 116 -Uncapped
    }
}
