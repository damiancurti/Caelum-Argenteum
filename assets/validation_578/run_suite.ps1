param([string]$Prefix = 'complete')
$ErrorActionPreference = 'Stop'
# Native processes run sequentially, hidden, unpaused and at 5% audio.
$cases = @(
    @{Label='gameplay';Script='gameplay'},
    @{Label='controls';Script='controls'},
    @{Label='model';Script='smoke'},
    @{Label='live';Script='live'},
    @{Label='save';Script='live-save'},
    @{Label='load';Script='live-load';LoadGame='ca479-live.zds'},
    @{Label='legacy';Script='legacy-load';LoadGame='ca479-legacy-v2.zds';Addon='legacy-fixture.pk3'},
    @{Label='gallery';Script='gallery'}
)
foreach ($case in $cases) {
    $case.Label = "$Prefix-$($case.Label)"
    & (Join-Path $PSScriptRoot 'run_native.ps1') @case -Checks
}
