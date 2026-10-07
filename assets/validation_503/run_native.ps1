param(
    [string]$Engine = 'C:\Program Files (x86)\GZDoom\gzdoom.exe',
    [string]$Iwad = 'C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD',
    [string]$Label = 'baseline-arrival',
    [string]$Package = 'baseline.pk3',
    [string]$Addon = 'benchmark.pk3',
    [string]$Map = 'MAP06',
    [string]$Script = '',
    [string]$Language = 'enu',
    [string]$LoadGame = ''
)
$ErrorActionPreference = 'Stop'
if (Get-Process gzdoom -ErrorAction SilentlyContinue) { throw "Wait for the existing GZDoom run to exit; native runs must not overlap." }
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build\issue119'
$config = Join-Path $work "$Label.ini"
if (Test-Path -LiteralPath $config) { throw "Use a new label; the original config must remain reproducible." }
$initial = "[LastRun]`nVersion=225`n[GlobalSettings]`nvid_preferbackend=1`nvid_vsync=false`nvid_maxfps=60`nvid_activeinbackground=true`ncl_capfps=false`nvid_fullscreen=false`nvid_defwidth=1280`nvid_defheight=720`nuse_mouse=false`nsnd_mastervolume=0.05`nlanguage=$Language`n"
[IO.File]::WriteAllText($config, $initial)
$argsList = @('-noautoload', '-nomouse', '-iwad', "`"$Iwad`"", '-file', "`"$work\$Package`"", "`"$work\$Addon`"", '-config', "`"$config`"", '-savedir', "`"$work`"", '-width', '1280', '-height', '720', '-window', '-rngseed', '116', '-skill', '2', '+logfile', "`"$work\$Label.txt`"", '+con_notifytime', '0')
if ($LoadGame) { $argsList += @('-loadgame', $LoadGame) }
else { $argsList += @('+map', $Map) }
if ($Script) { $argsList += @('+exec', "`"$work\$Script`"") }
$record = [ordered]@{
    label=$Label; started_utc=[DateTime]::UtcNow.ToString('o'); engine=$Engine;
    engine_sha256=(Get-FileHash -LiteralPath $Engine -Algorithm SHA256).Hash;
    iwad_sha256=(Get-FileHash -LiteralPath $Iwad -Algorithm SHA256).Hash;
    package_sha256=(Get-FileHash -LiteralPath (Join-Path $work $Package) -Algorithm SHA256).Hash;
    addon_sha256=(Get-FileHash -LiteralPath (Join-Path $work $Addon) -Algorithm SHA256).Hash;
    initial_config=$initial; arguments=$argsList;
    cpu=@(Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors);
    gpu=@(Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion);
    os=Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,TotalVisibleMemorySize
}
$process = Start-Process -FilePath $Engine -ArgumentList $argsList -WorkingDirectory $work -WindowStyle Hidden -PassThru
$record.pid = $process.Id
$record | ConvertTo-Json -Depth 6 | Set-Content -Encoding utf8 -LiteralPath (Join-Path $work "$Label-run.json")
Write-Output "Started $Label PID $($process.Id); raw evidence: build/issue119/$Label.txt"
