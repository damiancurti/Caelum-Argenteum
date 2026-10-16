param(
    [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$Directory,
    [ValidateSet('early','render','extended')][string]$Suite='early',
    [string]$Fixture='observer.pk3'
)
$ErrorActionPreference='Stop'
$plans=@{
    early=@('base','thermal-off','target-3s','models','models','target-3s','thermal-off','base')
    render=@('base','models','models','base')
    extended=@('profile-thermal-off','base','thermal-off')
}
$index=0
foreach($variant in $plans[$Suite]) {
    $index++
    $script=if($Suite -eq 'render'){'render.cfg'}elseif($Suite -eq 'extended' -and !$variant.StartsWith('profile-')){'long.cfg'}else{'study.cfg'}
    & "$PSScriptRoot\run_native.ps1" -Directory $Directory -Label "$Suite-$index-$variant" -Runtime "$variant.pk3" -Fixture $Fixture -Script $script -Seed 116 -Uncapped
}
