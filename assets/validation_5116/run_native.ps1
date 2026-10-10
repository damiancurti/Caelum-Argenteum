param(
    [string]$Label = 'compile-01',
    [string]$Fixture = 'compile',
    [string]$Script = 'compile.cfg',
    [string]$LoadGame = '',
    [string]$Map = 'CA163',
    [string]$Language = 'enu',
    [string]$Engine = 'C:\Program Files (x86)\GZDoom\gzdoom.exe',
    [string]$Iwad = 'C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD',
    [switch]$Baseline,
    [switch]$Interactive
)
$ErrorActionPreference='Stop'
if(Get-Process gzdoom -ErrorAction SilentlyContinue){throw 'Wait for the existing native run to finish.'}
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work=Join-Path $root 'build\issue163'
if($Script -and !(Test-Path -LiteralPath (Join-Path $work $Script))){throw "Missing script: $Script"}
$config=Join-Path $work "$Label.ini"
if(Test-Path -LiteralPath $config){throw 'Choose a new label to preserve the original run.'}
$initial="[LastRun]`nVersion=225`n[GlobalSettings]`nvid_preferbackend=1`nvid_vsync=false`nvid_maxfps=60`nvid_activeinbackground=true`ni_pauseinbackground=false`nvid_lowerinbackground=false`ni_soundinbackground=true`ncl_capfps=false`nvid_fullscreen=false`nvid_defwidth=1280`nwin_w=1296`nwin_h=759`nwin_maximized=false`nvid_defheight=720`nuse_mouse=false`nsnd_mastervolume=0.05`nlanguage=$Language`n"
if($Interactive){$initial=$initial.Replace('use_mouse=false','use_mouse=true')}
[IO.File]::WriteAllText($config,$initial)
$runtime=if($Baseline){"baseline.pk3"}else{"production.pk3"}
$files=@("`"$work\$runtime`"")
$files+=@("`"$work\$Fixture.pk3`"")
$arguments=@('-noautoload','-nomouse','-iwad',"`"$Iwad`"",'-file')+$files+@('-config',"`"$config`"",'-savedir',"`"$work`"",'-width','1280','-height','720','-window','-rngseed','163','-skill','2','+logfile',"`"$work\$Label.txt`"",'+con_notifytime','0')
if($LoadGame){$arguments+=@('-loadgame',"`"$LoadGame`"")}else{$arguments+=@('+map',$Map)}
if($Script){$arguments+=@('+exec',"`"$work\$Script`"")}
if($Interactive){$arguments=@($arguments | Where-Object {$_ -ne '-nomouse'})}
$record=[ordered]@{label=$Label;started_utc=[DateTime]::UtcNow.ToString('o');arguments=$arguments;initial_config=$initial;engine_sha256=(Get-FileHash -LiteralPath $Engine).Hash;baseline_sha256=(Get-FileHash -LiteralPath "$work\baseline.pk3").Hash;production_sha256=$(if(!$Baseline){(Get-FileHash -LiteralPath "$work\production.pk3").Hash}else{''});fixture_sha256=(Get-FileHash -LiteralPath "$work\$Fixture.pk3").Hash}
$style=if($Interactive){'Normal'}else{'Hidden'}
$process=Start-Process -FilePath $Engine -ArgumentList $arguments -WorkingDirectory $work -WindowStyle $style -PassThru
$record.pid=$process.Id
$record|ConvertTo-Json -Depth 5|Set-Content -Encoding utf8 -LiteralPath "$work\$Label-run.json"
Write-Output "Started $Label PID $($process.Id)."
$null=$process.Handle
$process.WaitForExit()
$record.exit_code=$process.ExitCode;$record.finished_utc=[DateTime]::UtcNow.ToString('o')
$record|ConvertTo-Json -Depth 5|Set-Content -Encoding utf8 -LiteralPath "$work\$Label-run.json"
if($process.ExitCode -ne 0){throw "Native run failed: $Label ($($process.ExitCode))."}
