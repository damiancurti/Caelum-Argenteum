# One-time recovery for the initial helper's missing Vulkan process-exit event.
$ErrorActionPreference = 'Stop'
$work = Join-Path (Split-Path (Split-Path $PSScriptRoot)) 'build/issue132'
$exe = Join-Path $work 'PresentMon-2.6.0-x64.exe'
$ready = Get-Content -LiteralPath (Join-Path $work 'capture-ready.json') -Raw | ConvertFrom-Json
$old = Get-Process -Id $ready.pid -ErrorAction SilentlyContinue
if ($old -and $old.Id -ne $PID -and $old.ProcessName -eq 'powershell' -and
    [Math]::Abs(($old.StartTime.ToUniversalTime()-[DateTime]::Parse($ready.started_utc).ToUniversalTime()).TotalSeconds) -lt 10) {
    Stop-Process -Id $old.Id
}
& $exe --session_name CA132-staged-natural-a --terminate_existing_session
Start-Sleep -Seconds 3
@{ completed_utc=[DateTime]::UtcNow.ToString('o'); recovery='Missing exit event; session stopped explicitly before restarting helper.' } |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $work 'staged-natural-a.capture-done.json') -Encoding utf8
& (Join-Path $PSScriptRoot 'capture_admin.ps1')
