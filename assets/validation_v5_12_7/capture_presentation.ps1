param(
    [ValidateRange(15,900)][int]$Seconds=90,
    [Parameter(Mandatory=$true)][string]$OutputDirectory,
    [switch]$PresentationOnly,
    [ValidateRange(0,2147483647)][int]$TargetProcessId=0,
    [switch]$ApplicationOnly,
    [ValidateSet('qpc','date')][string]$TimeFormat='qpc'
)
$ErrorActionPreference='Stop'
$captureRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$captureTool=Join-Path $captureRoot 'build/issue431/tools/PresentMon-2.6.0-x64.exe'
$captureHash='B2A706BC6AD475749E3B7E3409263AA1E6906D45BDCF993F6DBC0F660188F1AF'
if ((Get-FileHash -LiteralPath $captureTool -Algorithm SHA256).Hash -ne $captureHash) {
    throw 'PresentMon checksum differs from the previously verified official 2.6.0 binary.'
}
$captureOut=[IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $captureOut | Out-Null
$captureMeta=Join-Path $captureOut 'capture.json'
if (Test-Path -LiteralPath $captureMeta) { throw 'Choose a fresh output directory to retain earlier evidence.' }
$captureCsv=Join-Path $captureOut 'frames.csv'
$captureRecord=@{
    started_utc=[DateTime]::UtcNow.ToString('o'); hard_limit_seconds=$Seconds;
    recording_seconds=($Seconds-10); tool_sha256=$captureHash; csv=$captureCsv;
    administrator=([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator);
    session_id=(Get-Process -Id $PID).SessionId; parent_pid=$PID;
    status='starting'; forced_stop=$false; exit_code=$null; presentation_only=[bool]$PresentationOnly;
    application_only=[bool]$ApplicationOnly; target_pid=$TargetProcessId; time_format=$TimeFormat;
    source='https://github.com/GameTechDev/PresentMon/releases/tag/v2.6.0'
}
$captureRecord | ConvertTo-Json | Set-Content -LiteralPath $captureMeta -Encoding UTF8
$captureChild=$null
try {
    # Separate native pipes avoid PowerShell NativeCommandError suppressing the
    # final report. This helper never elevates itself or changes permissions.
    $captureTarget=if($TargetProcessId){@('--process_id',$TargetProcessId.ToString())}else{@('--process_name','gzdoom.exe')}
    $captureTime=if($TimeFormat -eq 'qpc'){'--qpc_time_ms'}else{'--date_time'}
    $captureArgs=$captureTarget+@('--session_name',('Caelum435-'+[Guid]::NewGuid().ToString('N')),
        $captureTime,'--timed',($Seconds-10).ToString(),'--terminate_after_timed','--no_console_stats',
        '--output_file',('"'+$captureCsv+'"'))
    # Retain presentation/display tracking while excluding optional GPU/input
    # event streams when diagnosing a trace with lost events.
    if($PresentationOnly){$captureArgs+=@('--no_track_gpu','--no_track_input')}
    if($ApplicationOnly){$captureArgs+=@('--no_track_display')}
    $captureChild=Start-Process -FilePath $captureTool -ArgumentList $captureArgs -WorkingDirectory $captureOut `
        -RedirectStandardOutput (Join-Path $captureOut 'stdout.log') -RedirectStandardError (Join-Path $captureOut 'stderr.log') `
        -WindowStyle Hidden -PassThru
    # Cache the native handle before exit so Windows PowerShell retains ExitCode.
    $null=$captureChild.Handle
    $captureRecord.child_pid=$captureChild.Id
    $captureRecord.arguments=$captureArgs
    $captureRecord.status='recording'
    $captureRecord | ConvertTo-Json | Set-Content -LiteralPath $captureMeta -Encoding UTF8
    # Reserve ten seconds for native trace draining within the overall limit.
    if (-not $captureChild.WaitForExit($Seconds*1000)) {
        $captureRecord.forced_stop=$true
        $captureChild.Kill()
        $captureChild.WaitForExit(5000) | Out-Null
    }
    $captureRecord.exit_code=$captureChild.ExitCode
    $captureRecord.status=if($captureRecord.forced_stop){'deadline'}else{'finished'}
} catch {
    $captureRecord.status='failed';$captureRecord.error=$_.Exception.Message
} finally {
    if($captureChild -ne $null -and -not $captureChild.HasExited) {
        $captureRecord.forced_stop=$true
        $captureChild.Kill()
    }
    $captureRecord.ended_utc=[DateTime]::UtcNow.ToString('o')
    $captureRecord.csv_exists=Test-Path -LiteralPath $captureCsv
    $captureRecord.lost_events=0
    $captureRecord.lost_buffers=0
    $captureErrorFile=Join-Path $captureOut 'stderr.log'
    if(Test-Path -LiteralPath $captureErrorFile){
        $captureErrorText=Get-Content -LiteralPath $captureErrorFile -Raw
        if($captureErrorText -match '(\d+) ETW events were lost'){$captureRecord.lost_events=[long]$Matches[1]}
        if($captureErrorText -match '(\d+) ETW buffers were lost'){$captureRecord.lost_buffers=[long]$Matches[1]}
    }
    if($captureRecord.status -eq 'finished' -and -not $captureRecord.csv_exists){$captureRecord.status='no_frames'}
    if($captureRecord.status -eq 'finished' -and ($captureRecord.lost_events -gt 0 -or $captureRecord.lost_buffers -gt 0)){$captureRecord.status='lost_events'}
    $captureRecord | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $captureMeta -Encoding UTF8
}
if($captureRecord.status -ne 'finished' -or $captureRecord.exit_code -ne 0 -or -not $captureRecord.csv_exists){exit 1}
