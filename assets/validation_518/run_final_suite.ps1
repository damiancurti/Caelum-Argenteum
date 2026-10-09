param([int]$StartIndex=0,[switch]$CurrentOnly)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build/issue137'
$jobs = @(
    @('checks-cells-final','current','checks','checks','CA137 COMPLETE checks=14 failures=0'),
    @('invariance-cells-final','current','invariance','invariance-after','CA137 COMPLETE checks=1499 failures=0'),
    @('gallery-before-final-c','baseline','gallery','gallery','CA137 GALLERY COMPLETE'),
    @('gallery-cells-final','current','gallery','gallery','CA137 GALLERY COMPLETE'),
    @('showcase-before-final','baseline','showcase','showcase','CA137 SHOWCASE COMPLETE'),
    @('showcase-cells-final','current','showcase','showcase','CA137 SHOWCASE COMPLETE'),
    @('water-cells-final','current','water','water','CA137 WATER COMPLETE'),
    @('cost-current-0-cells','current','stress','stress-0','CA137 STRESS COMPLETE failures=0'),
    @('cost-current-24-cells','current','stress','stress-24','CA137 STRESS COMPLETE failures=0'),
    @('cost-current-499-cells','current','stress','stress-499','CA137 STRESS COMPLETE failures=0'),
    @('battle-before-final','baseline','stress','battle','CA137 STRESS COMPLETE failures=0'),
    @('battle-cells-final','current','stress','battle','CA137 STRESS COMPLETE failures=0')
)
for ($jobIndex=$StartIndex; $jobIndex -lt $jobs.Count; $jobIndex++) {
    $job=$jobs[$jobIndex]
    if ($CurrentOnly -and $job[1] -ne 'current') { continue }
    $bench = Join-Path $work 'benchmarks.txt'
    $start = if (Test-Path -LiteralPath $bench) { (Get-Item -LiteralPath $bench).Length } else { 0 }
    & (Join-Path $PSScriptRoot 'run_check.ps1') -Label $job[0] -Package ($job[1]+'/caelum_argenteum_dev.pk3') -Addon ($job[2]+'.pk3') -Script ($job[3]+'.cfg') -Expected $job[4]
    if (Test-Path -LiteralPath $bench) {
        $bytes = [IO.File]::ReadAllBytes($bench)
        if ($bytes.Length -gt $start) {
            $slice = New-Object byte[] ($bytes.Length-$start)
            [Array]::Copy($bytes,$start,$slice,0,$slice.Length)
            [IO.File]::WriteAllBytes((Join-Path $PSScriptRoot ($job[0]+'-bench.txt')),$slice)
        }
    }
}
