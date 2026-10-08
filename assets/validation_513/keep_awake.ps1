param([int]$MaximumHours = 4, [string]$RecordName = 'power-request', [string]$ReleaseName = 'release-awake.signal')
$ErrorActionPreference = 'Stop'
$work = Join-Path (Split-Path (Split-Path $PSScriptRoot)) 'build/issue133'
$release = Join-Path $work $ReleaseName
if (Test-Path -LiteralPath $release) { throw 'Use a fresh release marker before starting a new request.' }
Add-Type @'
using System.Runtime.InteropServices;
public static class CA133Power {
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern uint SetThreadExecutionState(uint flags);
}
'@
$record = [ordered]@{
    started_utc = [DateTime]::UtcNow.ToString('o')
    pid = $PID
    active_plan_before = (powercfg /getactivescheme | Out-String).Trim()
    mechanism = 'Thread-scoped ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED; no power-plan mutation'
    maximum_hours = $MaximumHours
}
$path = Join-Path $work ($RecordName + '.json')
try {
    $previous = [CA133Power]::SetThreadExecutionState([uint32]2147483651)
    if ($previous -eq 0) { throw 'SetThreadExecutionState failed.' }
    $record.previous_thread_state = $previous
    $record | ConvertTo-Json | Set-Content -LiteralPath $path -Encoding utf8
    $deadline = [DateTime]::UtcNow.AddHours($MaximumHours)
    while (!(Test-Path -LiteralPath $release) -and [DateTime]::UtcNow -lt $deadline) {
        Start-Sleep -Seconds 1
    }
} finally {
    $record.release_result = [CA133Power]::SetThreadExecutionState([uint32]2147483648)
    $record.released_utc = [DateTime]::UtcNow.ToString('o')
    $record.active_plan_after = (powercfg /getactivescheme | Out-String).Trim()
    $record | ConvertTo-Json | Set-Content -LiteralPath $path -Encoding utf8
}
