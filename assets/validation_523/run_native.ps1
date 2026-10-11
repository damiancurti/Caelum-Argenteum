param(
    [string]$Label = 'base-01',
    [string]$Fixture = 'fight',
    [string]$RuntimeAlias = '',
    [string]$Script = 'fight.cfg',
    [string]$LoadGame = '',
    [string]$ConfigSource = '',
    [string]$Map = 'MAP01',
    [string]$Language = 'enu',
    [int]$Width = 1280,
    [int]$Height = 720,
    [string]$Engine = 'C:\Program Files (x86)\GZDoom\gzdoom.exe',
    [string]$Iwad = 'C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD',
    [switch]$Baseline,
    [switch]$ExpectRegression,
    [switch]$Interactive
)
$ErrorActionPreference='Stop'
if(Get-CimInstance Win32_Process -Filter "Name='gzdoom.exe'" | Where-Object {$_.CommandLine -like '*build\issue180\*'}){throw 'Wait for the existing issue180 native run to finish.'}
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work=Join-Path $root 'build\issue180'
if($Script -and !(Test-Path -LiteralPath (Join-Path $work $Script))){throw "Missing script: $Script"}
$config=Join-Path $work "$Label.ini"
if(Test-Path -LiteralPath $config){throw 'Choose a new label to preserve the original run.'}
$initial="[LastRun]`nVersion=225`n[GlobalSettings]`nvid_preferbackend=1`nvid_vsync=false`nvid_maxfps=60`nvid_activeinbackground=true`ni_pauseinbackground=false`nvid_lowerinbackground=false`ni_soundinbackground=true`ncl_capfps=false`nvid_fullscreen=false`nvid_defwidth=1280`nwin_w=1296`nwin_h=759`nwin_maximized=false`nvid_defheight=720`nuse_mouse=false`nsnd_mastervolume=0.05`nlanguage=$Language`n"
if($Interactive){$initial=$initial.Replace('use_mouse=false','use_mouse=true')}
$initial=$initial.Replace('vid_defwidth=1280',"vid_defwidth=$Width").Replace('vid_defheight=720',"vid_defheight=$Height").Replace('win_w=1296',"win_w=$($Width+16)").Replace('win_h=759',"win_h=$($Height+39)")
if($ConfigSource){
    $initial=[IO.File]::ReadAllText((Resolve-Path -LiteralPath $ConfigSource).Path)
}
[IO.File]::WriteAllText($config,$initial)
$runtime=if($Baseline){"baseline.pk3"}elseif($RuntimeAlias){$RuntimeAlias}else{"production.pk3"}
$files=@("`"$work\$runtime`"")
$files+=@("`"$work\$Fixture.pk3`"")
$arguments=@('-noautoload','-nomouse','-iwad',"`"$Iwad`"",'-file')+$files+@('-config',"`"$config`"",'-savedir',"`"$work`"",'-width','1280','-height','720','-window','-rngseed','180','-skill','2','+logfile',"`"$work\$Label.txt`"",'+con_notifytime','0')
if($LoadGame){$arguments+=@('-loadgame',"`"$LoadGame`"")}else{$arguments+=@('+map',$Map)}
$arguments[$arguments.IndexOf('-width')+1]="$Width"
$arguments[$arguments.IndexOf('-height')+1]="$Height"
if($Script){$arguments+=@('+exec',"`"$work\$Script`"")}
if($Interactive){$arguments=@($arguments | Where-Object {$_ -ne '-nomouse'})}
$record=[ordered]@{label=$Label;started_utc=[DateTime]::UtcNow.ToString('o');arguments=$arguments;initial_config=$initial;engine_sha256=(Get-FileHash -LiteralPath $Engine).Hash;baseline_sha256=(Get-FileHash -LiteralPath "$work\baseline.pk3").Hash;production_sha256=$(if(!$Baseline){(Get-FileHash -LiteralPath "$work\production.pk3").Hash}else{''});fixture_sha256=(Get-FileHash -LiteralPath "$work\$Fixture.pk3").Hash}
$style=if($Interactive){'Normal'}else{'Hidden'}
$process=Start-Process -FilePath $Engine -ArgumentList $arguments -WorkingDirectory $work -WindowStyle $style -PassThru
$record.pid=$process.Id
$record|ConvertTo-Json -Depth 5|Set-Content -Encoding utf8 -LiteralPath "$work\$Label-run.json"
Write-Output "Started $Label PID $($process.Id)."
$null=$process.Handle
$watch=[Diagnostics.Stopwatch]::StartNew();$marks=@{};$finishedByMarker=$false
while(!$process.WaitForExit(10)) {
    $log=Join-Path $work "$Label.txt"
    if(Test-Path -LiteralPath $log) {
        $tail=Get-Content -LiteralPath $log -Tail 12 -Encoding UTF8
        foreach($line in $tail){if($line -match 'CA180 MARK (\w+)'){$tag=$Matches[1];if(!$marks.ContainsKey($tag)){$marks[$tag]=$watch.Elapsed.TotalSeconds;Write-Output "Phase $tag at $($marks[$tag]) seconds."}}}
        if($tail -match 'CA180 DONE'){$finishedByMarker=$true;Stop-Process -Id $process.Id;$process.WaitForExit();break}
        if($tail -match 'Script error|VM execution aborted|DIED WITH FATAL ERROR') {
            Stop-Process -Id $process.Id
            throw "Native run failed; preserved diagnostics: $log"
        }
    }
}
$record.phase_seconds=$marks;$record.stopped_after_completion=$finishedByMarker;$record.exit_code=$process.ExitCode;$record.finished_utc=[DateTime]::UtcNow.ToString('o')
$record|ConvertTo-Json -Depth 5|Set-Content -Encoding utf8 -LiteralPath "$work\$Label-run.json"
if($process.ExitCode -ne 0 -and !$finishedByMarker){throw "Native run failed: $Label ($($process.ExitCode))."}


if(!$ExpectRegression -and (Select-String -LiteralPath "$work\$Label.txt" -Pattern "CA180 FAIL|Script error|VM execution aborted|DIED WITH FATAL ERROR|This savegame needs" -Quiet)){throw "Native checks failed: $Label"}
