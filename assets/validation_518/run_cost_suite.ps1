param()
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build/issue137'
foreach ($population in @(0,24,499)) {
    foreach ($variant in @('baseline','current')) {
        $label = "cost-$variant-$population-b"
        $bench = Join-Path $work 'benchmarks.txt'
        $start = if (Test-Path -LiteralPath $bench) { (Get-Item -LiteralPath $bench).Length } else { 0 }
        & (Join-Path $PSScriptRoot 'run_check.ps1') -Label $label -Package "$variant/caelum_argenteum_dev.pk3" -Addon stress.pk3 -Script "stress-$population.cfg" -Expected 'CA137 STRESS COMPLETE failures=0'
        $bytes = [IO.File]::ReadAllBytes($bench)
        $slice = New-Object byte[] ($bytes.Length-$start)
        [Array]::Copy($bytes,$start,$slice,0,$slice.Length)
        [IO.File]::WriteAllBytes((Join-Path $PSScriptRoot "$label-bench.txt"),$slice)
    }
}
