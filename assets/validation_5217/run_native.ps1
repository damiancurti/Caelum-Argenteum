param(
    [Parameter(Mandatory=$true)][string]$Label,
    [string]$Script='contract.cfg',
    [string]$Map='MAP01',
    [string]$LoadGame='',
    [string]$Runtime='production.pk3',
    [switch]$ExpectRegression,
    [string]$Engine='C:\Program Files (x86)\GZDoom\gzdoom.exe',
    [string]$Iwad='C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD'
)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work=Join-Path $root 'build\issue207'
if(Get-Process gzdoom -ErrorAction SilentlyContinue){throw 'Finish the previous native test first.'}
$config=Join-Path $work "$Label.ini"
if(Test-Path -LiteralPath $config){throw 'Choose a fresh label to retain evidence.'}
$initial="[LastRun]`nVersion=225`n[GlobalSettings]`nvid_preferbackend=1`nvid_vsync=true`nvid_maxfps=60`nvid_activeinbackground=true`ni_pauseinbackground=false`nvid_lowerinbackground=false`ni_soundinbackground=true`nvid_fullscreen=false`nvid_defwidth=960`nvid_defheight=540`nwin_w=976`nwin_h=579`nwin_maximized=false`nuse_mouse=false`nsnd_mastervolume=0.05`nlanguage=enu`n"
[IO.File]::WriteAllText($config,$initial)
$arguments=@('-noautoload','-nomouse','-iwad',"`"$Iwad`"",'-file',"`"$work\$Runtime`"","`"$work\contract.pk3`"",'-config',"`"$config`"",'-savedir',"`"$work`"",'-window','-width','960','-height','540','-rngseed','207','-skill','2','+logfile',"`"$work\$Label.txt`"",'+exec',"`"$work\$Script`"")
if($LoadGame){$arguments+=@('-loadgame',"`"$LoadGame`"")}else{$arguments+=@('+map',$Map)}
$record=[ordered]@{label=$Label;runtime=$Runtime;script=$Script;map=$Map;loadgame=$LoadGame;started_utc=[DateTime]::UtcNow.ToString('o');engine_sha256=(Get-FileHash -LiteralPath $Engine).Hash;runtime_sha256=(Get-FileHash -LiteralPath "$work\$Runtime").Hash;fixture_sha256=(Get-FileHash -LiteralPath "$work\contract.pk3").Hash;initial_config_sha256=(Get-FileHash -LiteralPath $config).Hash;audio=0.05;background_unpaused=$true}
Add-Type -TypeDefinition 'using System;using System.Runtime.InteropServices;public static class CA207Awake{[DllImport("kernel32.dll")]public static extern uint SetThreadExecutionState(uint flags);}'
$awake=[CA207Awake]::SetThreadExecutionState([uint32]2147483651)
$record.keep_awake_requested=($awake -ne 0)
try {
    $process=Start-Process -FilePath $Engine -ArgumentList $arguments -WorkingDirectory $work -WindowStyle Hidden -PassThru
    $null=$process.Handle
    Write-Output "Started $Label PID $($process.Id)."
    $timer=[Diagnostics.Stopwatch]::StartNew()
    while(!$process.WaitForExit(1000)){
        $log=Join-Path $work "$Label.txt"
        if((Test-Path -LiteralPath $log) -and (Select-String -LiteralPath $log -Pattern 'Script error|Unknown flag|Unable to resolve|errors while parsing|VM execution aborted|DIED WITH FATAL ERROR|This savegame needs' -Quiet)){
            Stop-Process -Id $process.Id
            throw "Native test error; inspect $log"
        }
        if($timer.Elapsed.TotalSeconds -gt 90){Stop-Process -Id $process.Id;throw 'Native test deadline exceeded; log retained.'}
    }
    $record.exit_code=$process.ExitCode
    if($process.ExitCode -ne 0){throw "Native process exited $($process.ExitCode)."}
    if(!$ExpectRegression -and (Select-String -LiteralPath "$work\$Label.txt" -Pattern 'CA207 FAIL' -Quiet)){throw 'Native assertion failed; log retained.'}
    if(!(Select-String -LiteralPath "$work\$Label.txt" -Pattern 'CA207 DONE' -Quiet)){throw 'Fixture completion marker missing.'}
    Write-Output "Completed $Label."
} finally {
    $record.keep_awake_released=([CA207Awake]::SetThreadExecutionState([uint32]2147483648) -ne 0)
    $record.finished_utc=[DateTime]::UtcNow.ToString('o')
    $record|ConvertTo-Json -Depth 5|Set-Content -LiteralPath "$work\$Label-run.json" -Encoding UTF8
}
