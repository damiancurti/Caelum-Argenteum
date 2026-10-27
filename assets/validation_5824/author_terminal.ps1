param([string]$Runtime='final24d')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $repo
Write-Host '#410 / CA410-WARDROBE-01'
Write-Host 'Inspect the wardrobe in the northwest first-floor bedroom. Use opens native storage; Shift+Use carries it.'
Write-Host 'Store and withdraw objects; close/reopen; save/load and verify unchanged contents.'
Write-Host 'Capacity:25 stacks,1000kg contents; empty furniture:153.8955961kg. This PRIVATE fixture keeps carry capacity2000kg for transport checks.'
Write-Host 'Placement requires approved land: mansion gardens, current owned/rented property, or unowned countryside. Bedroom rearrangement is not granted by the current camp land policy.'
Write-Host 'Other pending tests stay separate. Use ordinary inventory controls; no F-key macros are required.'
Read-Host 'Press Enter to launch'
$label='wardrobe-author-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
& (Join-Path $PSScriptRoot 'run_native.ps1') -Label $label -Runtime $Runtime -Script wardrobe-author -Checks -Addon wardrobe-checks.pk3 -Interactive -Language es
Read-Host 'Keep this terminal open while inspecting the game; press Enter when done'
