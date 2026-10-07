param([string]$StartAt = '')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build/issue128'
$aliasDirectory = Join-Path $work 'production-upgrade'
New-Item -ItemType Directory -Path $aliasDirectory -Force | Out-Null
$alias = Join-Path $aliasDirectory 'baseline.pk3'
$production = Join-Path $work 'production.pk3'
if (!(Test-Path -LiteralPath $alias)) { New-Item -ItemType HardLink -Path $alias -Target $production | Out-Null }
if ((Get-FileHash -LiteralPath $alias).Hash -ne (Get-FileHash -LiteralPath $production).Hash) { throw 'Upgrade alias differs from the final production package.' }
$runs = @(
    @('final-checks-b','production.pk3','checks.pk3','QA128A','checks.cfg','','CA128 COMPLETE checks=38 failures=0',0),
    @('final-load-b','production.pk3','checks.pk3','QA128A','load-checks.cfg','ca128_checks.zds','save or hub return restores population from actors',0),
    @('final-travel-b','production.pk3','checks.pk3','QA128A','travel.cfg','ca128_checks.zds','travel clears previous map population',0),
    @('old-save-upgrade-a','production-upgrade/baseline.pk3','battle.pk3','MAP06','upgrade.cfg','ca121_late_baseline-c.zds','CA128 BATTLE .*active=1 revision=2',2205),
    @('old-save-reload-a','production-upgrade/baseline.pk3','battle.pk3','MAP06','rollback.cfg','ca128_upgraded.zds','CA128 BATTLE .*active=1 revision=2',2240),
    @('old-save-rollback-a','baseline.pk3','observer.pk3','MAP06','rollback.cfg','ca121_late_baseline-c.zds','CA121 SIM',2135),
    @('final-guard-a','guard-oracle.pk3','battle.pk3','MAP06','oracle.cfg','','CA128 GUARD_VERIFIED',3500),
    @('final-cannon-a','cannon-oracle.pk3','battle.pk3','MAP06','oracle.cfg','','CA128 CANNON_VERIFIED',3500),
    @('count-current-a','counters-current.pk3','counters.pk3','MAP06','counters.cfg','','CA128 WORK',735),
    @('count-demand-a','counters-no-stagger.pk3','counters.pk3','MAP06','counters.cfg','','CA128 WORK',735),
    @('count-unshared-a','counters-no-candidates.pk3','counters.pk3','MAP06','counters.cfg','','CA128 WORK',735),
    @('count-pruned-a','counters-pruned-cannon.pk3','counters.pk3','MAP06','counters.cfg','','CA128 WORK',735),
    @('final-visual-a','production.pk3','battle.pk3','MAP06','visual.cfg','','CA128 BATTLE',3500)
)
$started = !$StartAt
foreach ($run in $runs) {
    if ($run[0] -eq $StartAt) { $started = $true }
    if (!$started) { continue }
    & (Join-Path $PSScriptRoot 'run_check.ps1') -Label $run[0] -Package $run[1] -Addon $run[2] -Map $run[3] -Script $run[4] -LoadGame $run[5] -Expected $run[6] -MinimumTic $run[7]
}
if (!$started) { throw "Unknown start label: $StartAt" }
