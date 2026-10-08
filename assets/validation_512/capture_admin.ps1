# Run manually in an elevated PowerShell. No installation or policy mutation.
$ErrorActionPreference = 'Stop'
$work = Join-Path (Split-Path (Split-Path $PSScriptRoot)) 'build/issue132'
$exe = Join-Path $work 'PresentMon-2.6.0-x64.exe'
$expectedHash = 'B2A706BC6AD475749E3B7E3409263AA1E6906D45BDCF993F6DBC0F660188F1AF'
if ((Get-FileHash -LiteralPath $exe).Hash -ne $expectedHash) { throw 'Unexpected PresentMon binary.' }
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Open PowerShell as administrator for this measurement.' }
$stop = Join-Path $work 'capture-stop.signal'
if (Test-Path -LiteralPath $stop) { throw 'This capture session has already ended.' }
$record = @{ pid=$PID; started_utc=[DateTime]::UtcNow.ToString('o'); binary_sha256=$expectedHash }
$record | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $work 'capture-ready.json') -Encoding utf8
Write-Output 'CA132 capture ready. Waiting for owned GZDoom measurement jobs; maximum eight hours.'
$deadline = [DateTime]::UtcNow.AddHours(8)
try {
    while (!(Test-Path -LiteralPath $stop) -and [DateTime]::UtcNow -lt $deadline) {
        foreach ($job in Get-ChildItem -LiteralPath $work -Filter '*.capture-request.json') {
            $request = Get-Content -LiteralPath $job.FullName -Raw | ConvertFrom-Json
            $label = [string]$request.label
            if ($label -notmatch '^[a-z0-9-]+$') { throw 'Invalid capture label.' }
            $done = Join-Path $work ($label+'.capture-done.json')
            if (Test-Path -LiteralPath $done) { continue }
            $target = Get-Process -Id ([int]$request.pid) -ErrorAction SilentlyContinue
            if (!$target -or $target.ProcessName -ne 'gzdoom') { continue }
            $run = Get-Content -LiteralPath (Join-Path $work ($label+'-run.json')) -Raw | ConvertFrom-Json
            if ([Math]::Abs(($target.StartTime.ToUniversalTime()-[DateTime]::Parse($run.started_utc).ToUniversalTime()).TotalSeconds) -gt 30) { continue }
            $output = Join-Path $work ($label+'-present.csv')
            $argsList = @('--process_id', $target.Id, '--session_name', "CA132-$label", '--output_file', $output,
                '--qpc_time_ms', '--no_console_stats', '--terminate_on_proc_exit', '--timed', '10800', '--terminate_after_timed')
            Write-Output "Recording $label, GZDoom PID $($target.Id)."
            $capture = Start-Process -FilePath $exe -ArgumentList $argsList -WindowStyle Hidden -PassThru `
                -RedirectStandardOutput (Join-Path $work ($label+'-present.out.txt')) `
                -RedirectStandardError (Join-Path $work ($label+'-present.err.txt'))
            @{ pid=$capture.Id; target_pid=$target.Id; started_utc=[DateTime]::UtcNow.ToString('o') } |
                ConvertTo-Json | Set-Content -LiteralPath (Join-Path $work ($label+'.capture-started.json')) -Encoding utf8
            # Some Vulkan traces do not receive a usable process-exit event.
            # Own the termination explicitly instead of relying on that event.
            while (!$capture.HasExited -and !$target.HasExited -and !(Test-Path -LiteralPath $stop)) {
                $null = $capture.WaitForExit(500)
            }
            if (!$capture.HasExited) {
                & $exe --session_name "CA132-$label" --terminate_existing_session
                if (!$capture.WaitForExit(10000)) { Stop-Process -Id $capture.Id }
            }
            @{ exit_code=$capture.ExitCode; completed_utc=[DateTime]::UtcNow.ToString('o') } |
                ConvertTo-Json | Set-Content -LiteralPath $done -Encoding utf8
        }
        Start-Sleep -Seconds 1
    }
} finally {
    $record.ended_utc=[DateTime]::UtcNow.ToString('o')
    $record | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $work 'capture-helper.json') -Encoding utf8
}
