$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work=Join-Path $root 'build\issue315-contract01'
if(Get-Process gzdoom -ErrorAction SilentlyContinue){throw 'Existing engine retained.'}
if(Test-Path "$work\smoke.ini"){throw 'Use a fresh isolated run; existing evidence retained.'}
$config="[LastRun]`nVersion=225`n[GlobalSettings]`nvid_preferbackend=1`nvid_vsync=true`nvid_maxfps=60`nvid_activeinbackground=true`ni_pauseinbackground=false`nvid_lowerinbackground=false`ni_soundinbackground=true`nvid_fullscreen=false`nuse_mouse=false`nsnd_mastervolume=0.05`n"
[IO.File]::WriteAllText("$work\smoke.ini",$config)
[IO.File]::WriteAllText("$work\smoke.cfg","wait 100; quit`n")
$engine='C:\Program Files (x86)\GZDoom\gzdoom.exe'
$iwad='C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD'
$argsList=@('-noautoload','-nomouse','-iwad',"`"$iwad`"",'-file',"`"$work\production.pk3`"","`"$work\smoke.pk3`"",'-config',"`"$work\smoke.ini`"",'-savedir',"`"$work`"",'-width','1280','-height','720','-window','+logfile',"`"$work\smoke.txt`"",'+map','MAP01','+exec',"`"$work\smoke.cfg`"")
$record=@{arguments=$argsList;started_utc=[DateTime]::UtcNow.ToString('o');engine_sha256=(Get-FileHash $engine).Hash;runtime_sha256=(Get-FileHash "$work\production.pk3").Hash;fixture_sha256=(Get-FileHash "$work\smoke.pk3").Hash}
$process=Start-Process $engine -ArgumentList $argsList -WorkingDirectory $work -WindowStyle Hidden -PassThru
$null=$process.Handle
if(!$process.WaitForExit(60000)){Stop-Process -Id $process.Id;throw 'Native smoke timed out; log retained.'}
$record.exit_code=$process.ExitCode;$record.finished_utc=[DateTime]::UtcNow.ToString('o')
$record | ConvertTo-Json -Depth 3 | Set-Content "$work\smoke-run.json" -Encoding utf8
$log=[IO.File]::ReadAllText("$work\smoke.txt")
if($process.ExitCode -ne 0 -or $log -match 'Script error|VM execution aborted|DIED WITH FATAL ERROR' -or $log -notmatch 'CA315 PASS'){throw 'Native smoke failed; log retained.'}
Write-Host 'CA315 final MAP01 compilation/advance smoke passed.'
