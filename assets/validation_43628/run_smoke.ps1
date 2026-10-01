param(
    [Parameter(Mandatory=$true)][string]$Engine,
    [Parameter(Mandatory=$true)][string]$Iwad,
    [Parameter(Mandatory=$true)][string]$ExportZip,
    [Parameter(Mandatory=$true)][string]$OutputDirectory
)
$ErrorActionPreference = 'Stop'
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $OutputDirectory) { throw 'Use a new directory for clean-install evidence.' }
[IO.Directory]::CreateDirectory($OutputDirectory) | Out-Null
Expand-Archive -LiteralPath $ExportZip -DestinationPath $OutputDirectory
$Engine = (Resolve-Path -LiteralPath $Engine).Path
$Iwad = (Resolve-Path -LiteralPath $Iwad).Path
$results = @()
foreach ($map in @('MAP01','MAP02','MAP03','MAP06')) {
    $label = $map.ToLowerInvariant()
    $config = Join-Path $OutputDirectory "$label.ini"
    $log = Join-Path $OutputDirectory "$label.log"
    $commands = Join-Path $OutputDirectory "$label.cfg"
    $savePath = Join-Path $OutputDirectory 'saves'
    [IO.Directory]::CreateDirectory($savePath) | Out-Null
    [IO.File]::WriteAllText($config, "[GlobalSettings]`nvid_preferbackend=1`ni_pauseinbackground=false`nvid_activeinbackground=true`nvid_vsync=false`n")
    $sequence = "wait 105; echo ISSUE17_READY_$map; save smoke_$label; wait 35; load smoke_$label; wait 70; echo ISSUE17_DONE_$map; quit"
    [IO.File]::WriteAllText($commands, $sequence)
    $arguments = @('-iwad', ('"'+$Iwad+'"'), '-file', 'caelum_argenteum_dev.pk3',
        '-config', ('"'+$config+'"'), '-savedir', ('"'+$savePath+'"'),
        '-noautoload', '-window', '-width', '1280', '-height', '720',
        '+logfile', ('"'+$log+'"'), '+map', $map, '+exec', ('"'+$commands+'"'))
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $process = Start-Process -FilePath $Engine -ArgumentList $arguments -WorkingDirectory $OutputDirectory -WindowStyle Hidden -PassThru
    Write-Output "Issue17 $map owned process $($process.Id)"
    $timedOut = $false
    while (-not $process.WaitForExit(1000)) {
        if ($timer.Elapsed.TotalSeconds -ge 55) {
            Stop-Process -Id $process.Id
            $timedOut = $true
            break
        }
    }
    $process.WaitForExit()
    $text = if (Test-Path -LiteralPath $log) { [IO.File]::ReadAllText($log) } else { '' }
    $problems = @($text -split "`r?`n" | Where-Object { $_ -match '(?i)script error|fatal error|execution could not continue|VM execution aborted|unknown texture|not found|failed|cannot find|unable to' })
    $result = [ordered]@{
        map=$map; exit_code=$process.ExitCode; timeout=$timedOut;
        host_seconds=[Math]::Round($timer.Elapsed.TotalSeconds,3);
        package_sha256=(Get-FileHash (Join-Path $OutputDirectory 'caelum_argenteum_dev.pk3')).Hash.ToLowerInvariant();
        ready=$text.Contains("ISSUE17_READY_$map"); done=$text.Contains("ISSUE17_DONE_$map");
        saved=($text -match 'Game saved'); loaded=($text -match 'Loading game');
        engine_4142=($text -match 'g4\.14\.2'); problems=$problems;
        log="$label.log";
        scope='Direct map startup and native save/load only; not ordinary progression or author acceptance'
    }
    $results += $result
    $results | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $OutputDirectory 'SMOKE.json') -Encoding UTF8
    $result | ConvertTo-Json -Depth 4 -Compress | Write-Output
}
if (@($results | Where-Object { $_.timeout -or $_.exit_code -ne 0 -or -not $_.done -or -not $_.saved -or -not $_.loaded -or -not $_.engine_4142 -or $_.problems.Count -gt 0 }).Count) { exit 1 }
