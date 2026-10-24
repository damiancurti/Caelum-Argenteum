param([Parameter(Mandatory=$true)][string]$Label,[string]$Runtime='current',[string]$StartMap='MAP03',[int]$Pitch=0,[int]$Defenders=0)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$work=Join-Path $repo 'build/issue413'
$monitor='C:/GZDooMProjects/CaelumArgenteum/build/tools/PresentMon-2.6.0-x64.exe'
if(Get-Process gzdoom -ErrorAction SilentlyContinue){throw 'Close the existing game before measuring.'}
$csv=Join-Path $work ($Label+'.csv')
if(Test-Path -LiteralPath $csv){throw 'Use a fresh evidence label.'}
$script="wait 175; netevent ca413_camera $Pitch $Defenders; wait 175; netevent ca413_population; event ca413_perf_start; wait 350; event ca413_perf_stop; wait 5; quit"
[IO.File]::WriteAllText((Join-Path $work "$Label.cfg"),$script,[Text.UTF8Encoding]::new($false))
$arguments=@('--process_name','gzdoom.exe','--output_file',('"'+$csv+'"'),'--no_console_stats','--qpc_time_ms','--session_name','CaelumIssue413','--timed','55','--terminate_after_timed','--terminate_on_proc_exit')
$process=Start-Process -FilePath $monitor -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $work ($Label+'-presentmon.txt')) -RedirectStandardError (Join-Path $work ($Label+'-presentmon-error.txt'))
try {
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Label $Label -Runtime $Runtime -StartMap $StartMap -Checks -Addon performance.pk3 -Script $Label -TimeoutSeconds 50
    if(!$process.WaitForExit(5000)){$process.Kill();$process.WaitForExit()}
    [ordered]@{tool=$monitor;sha256=(Get-FileHash -LiteralPath $monitor).Hash;arguments=$arguments;exit_code=$process.ExitCode} | ConvertTo-Json -Depth 4 | Set-Content -Encoding utf8 -LiteralPath (Join-Path $work ($Label+'-presentmon.json'))
} finally {
    if(!$process.HasExited){$process.Kill();$process.WaitForExit()}
}
