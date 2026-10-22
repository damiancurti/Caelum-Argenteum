param([ValidateSet('current','compatibility','ui')][string]$Group = 'current', [string]$LabelPrefix = 'recheck')
$ErrorActionPreference = 'Stop'
$runs = switch ($Group) {
    'current' { @(
        @{Label='final-sources-01';Script='sources'},
        @{Label='final-save-01';Script='save'},
        @{Label='final-reload-01';Script='verify';LoadGame='ca408-current.zds'},
        @{Label='final-travel-01';Script='travel';LoadGame='ca408-current.zds'}
    ) }
    'compatibility' { @(
        @{Label='final-upgrade-01';Script='upgrade';LoadGame='ca408-legacy.zds';Addon='upgrade/legacy-checks.pk3'},
        @{Label='final-upgraded-reload-01';Script='upgraded-verify';LoadGame='ca408-upgraded.zds';Addon='upgrade/legacy-checks.pk3'},
        @{Label='final-rollback-01';Script='rollback';LoadGame='ca408-legacy.zds';Runtime='baseline'}
    ) }
    'ui' { @(
        @{Label='final-ui-es-01';Script='ui-es'},
        @{Label='final-ui-en-01';Script='ui-en'}
    ) }
}
foreach ($run in $runs) {
    $run.Label = $LabelPrefix + '-' + $run.Label
    & (Join-Path $PSScriptRoot 'run_native.ps1') @run -Checks
}
