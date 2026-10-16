param(
    [string]$Directory='issue304-author-03',
    [string]$Runtime='..\caelum_argenteum_dev.pk3'
)
$ErrorActionPreference='Stop'
Write-Host 'Issue #304 - MAP06 corpse retention and Redemption'
Write-Host 'F6: create 105 dead allied Mandingas. Wait one second.'
Write-Host 'F8: expect 0 alive, 100 visible corpses, 5 suspended corpses.'
Write-Host 'F7: cast Redemption. F8 should then report 105 alive and no corpses.'
Write-Host 'This isolated configuration and fixture do not change your campaign saves.'
$label='manual-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
& "$PSScriptRoot\run_native.ps1" -Directory $Directory -Label $label -Runtime $Runtime -Fixture author.pk3 -Script author.cfg -Language esp -Interactive
