param([string]$Directory='issue304-final-01',[string]$AuthorDirectory='issue304-author-03')
$ErrorActionPreference='Stop'
foreach($case in @('corpses','redemption','save','load','travel','outside','player')) {
    $options=@{Directory=$Directory;Label="$case-final";Script="$case.cfg"}
    if($case -in @('load','travel')) {
        $options.LoadGame='corpses.zds'
    }
    if($case -eq 'outside'){$options.Map='MAP98'}
    & "$PSScriptRoot\run_native.ps1" @options
}
foreach($case in @('clock','smoke')) {
    & "$PSScriptRoot\run_native.ps1" -Directory $AuthorDirectory -Label "$case-final" -Runtime "..\$Directory\production.pk3" -Fixture author.pk3 -Script "$case.cfg"
}
