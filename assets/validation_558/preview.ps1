param([string]$Directory = 'issue369-coat-final08', [switch]$MenuOnly)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location -LiteralPath $root
Write-Host '#369 / 5.5.8 - Bull model author preview'
Write-Host 'The frozen final package runs separately from ordinary saves. Audio: 5%.'
Write-Host 'Preview player is invulnerable. This is a visual/encounter fixture.'
Write-Host 'Room: F1 reset; F2 walk; F3 run; F4 prepare; F5 gore; F6 pain; F7 rest; F8 death.'
Write-Host 'MAP01: F5 releases the native encounter; F8 defeats the bull to inspect its fade.'
Write-Host 'Both: F9 toggles original sprites/model; normal movement looks around the bull.'
Write-Host 'Room F10: frontal inspection. F11: whole-body view (approved 1.5 visual scale).'
Write-Host 'Close GZDoom to return here. This terminal remains open.'
$first = !$MenuOnly
while ($true) {
    if ($first) { $choice='1'; $first=$false }
    else { $choice = Read-Host '1 = visual room, 2 = MAP01 encounter, 0 = finish' }
    if ($choice -eq '0') { break }
    if ($choice -notin @('1','2')) { continue }
    $script = if ($choice -eq '1') { 'manual.cfg' } else { 'manual-map.cfg' }
    $map = if ($choice -eq '1') { 'TBULL' } else { 'MAP01' }
    $label = 'author-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff')
    & "$PSScriptRoot\run_native.ps1" -Directory $Directory -Label $label -Script $script -Map $map -Interactive
}
