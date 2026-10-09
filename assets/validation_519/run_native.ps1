param(
    [string]$Engine = 'C:\Program Files (x86)\GZDoom\gzdoom.exe',
    [string]$Iwad = 'C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD',
    [string]$Label = 'baseline-arrival',
    [string]$Package = 'baseline.pk3',
    [string]$Addon = 'observer.pk3',
    [string]$Map = 'CA152',
    [string]$Script = '',
    [string]$Language = 'enu',
    [int]$Staged = 1,
    [int]$Width = 1280,
    [int]$Height = 720,
    [string]$LoadGame = '',
    [switch]$Interactive,
    [switch]$Controlled,
    [switch]$Capture
)
$ErrorActionPreference = 'Stop'
if (Get-Process gzdoom -ErrorAction SilentlyContinue) { throw "Wait for the existing GZDoom run to exit; native runs must not overlap." }
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $repo 'build\issue152'
$config = Join-Path $work "$Label.ini"
if (Test-Path -LiteralPath $config) { throw "Use a new label; the original config must remain reproducible." }
$windowWidth = $Width + 16
$windowHeight = $Height + 39
$initial = "[LastRun]`nVersion=225`n[GlobalSettings]`nvid_preferbackend=1`nvid_vsync=false`nvid_maxfps=60`nvid_activeinbackground=true`ni_pauseinbackground=false`nvid_lowerinbackground=false`ni_soundinbackground=true`ncl_capfps=false`nvid_fullscreen=false`nvid_defwidth=$Width`nwin_w=$windowWidth`nwin_h=$windowHeight`nwin_maximized=false`nvid_defheight=$Height`nuse_mouse=false`nsnd_mastervolume=0.05`nlanguage=$Language`n"
if ($Interactive -and !$Controlled) { $initial = $initial.Replace('use_mouse=false','use_mouse=true') }
[IO.File]::WriteAllText($config, $initial)
$argsList = @('-noautoload', '-nomouse', '-iwad', "`"$Iwad`"", '-file', "`"$work\$Package`"", "`"$work\$Addon`"", '-config', "`"$config`"", '-savedir', "`"$work`"", '-width', $Width, '-height', $Height, '-window', '-rngseed', '116', '-skill', '2', '+logfile', "`"$work\$Label.txt`"", '+con_notifytime', '0')
if ($Interactive -and !$Controlled) { $argsList = @($argsList | Where-Object { $_ -ne '-nomouse' }) }
$argsList += @('+set','ca_test_siege_reinforcements',$Staged)
if ($LoadGame) { $argsList += @('-loadgame', $LoadGame) }
else { $argsList += @('+map', $Map) }
if ($Script) {
    $commands = [IO.File]::ReadAllText((Join-Path $work $Script)).Replace('ca121_late', "ca121_late_$Label").Replace('screenshot ', "screenshot $Label-")
    if ($commands.Contains('exec bright.cfg')) {
        $nextScript = Join-Path $work "$Label-bright.cfg"
        $nextCommands = [IO.File]::ReadAllText((Join-Path $work 'bright.cfg')).Replace('screenshot ', "screenshot $Label-")
        [IO.File]::WriteAllText($nextScript,$nextCommands)
        $commands = $commands.Replace('exec bright.cfg',"exec $Label-bright.cfg")
    }
    $executionScript = Join-Path $work "$Label-exec.cfg"
    [IO.File]::WriteAllText($executionScript, $commands)
    # Chunk after adding labels: GZDoom's exec parser has a bounded line buffer.
    if ($commands.Length -gt 1500) {
        $chunks = [Collections.Generic.List[string]]::new()
        $part = ''
        foreach ($command in ($commands -split ';')) {
            if ($part.Length + $command.Length -gt 1500) { $chunks.Add($part); $part = '' }
            $part += $command + ';'
        }
        if ($part.Length) { $chunks.Add($part) }
        for ($index=0; $index -lt $chunks.Count; $index++) {
            $path = if ($index -eq 0) { $executionScript } else { Join-Path $work "$Label-part-$index.cfg" }
            $body = $chunks[$index]
            if ($index+1 -lt $chunks.Count) { $body += "exec $Label-part-$($index+1).cfg" }
            [IO.File]::WriteAllText($path,$body)
        }
    }
    $argsList += @('+exec', "`"$executionScript`"")
}
$record = [ordered]@{
    label=$Label; started_utc=[DateTime]::UtcNow.ToString('o'); engine=$Engine;
    engine_sha256=(Get-FileHash -LiteralPath $Engine -Algorithm SHA256).Hash;
    iwad_sha256=(Get-FileHash -LiteralPath $Iwad -Algorithm SHA256).Hash;
    package_sha256=(Get-FileHash -LiteralPath (Join-Path $work $Package) -Algorithm SHA256).Hash;
    addon_sha256=(Get-FileHash -LiteralPath (Join-Path $work $Addon) -Algorithm SHA256).Hash;
    initial_config=$initial; arguments=$argsList;
    benchmark_offset=$(if(Test-Path -LiteralPath (Join-Path $work 'benchmarks.txt')){(Get-Item -LiteralPath (Join-Path $work 'benchmarks.txt')).Length}else{0});
    command_script=$(if($Script){$commands}else{''});
    cpu=@(Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors);
    gpu=@(Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion);
    os=Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,TotalVisibleMemorySize
}
$style = if ($Interactive) { 'Normal' } else { 'Hidden' }
$process = Start-Process -FilePath $Engine -ArgumentList $argsList -WorkingDirectory $work -WindowStyle $style -PassThru
$record.pid = $process.Id
$record.qpc_ms = [Diagnostics.Stopwatch]::GetTimestamp()*1000.0/[Diagnostics.Stopwatch]::Frequency
$record.epoch_ms = ([DateTime]::UtcNow - [DateTime]'1970-01-01').TotalMilliseconds
if ($Capture) {
    @{ label=$Label; pid=$process.Id } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $work ($Label+'.capture-request.json')) -Encoding utf8
}
$record | ConvertTo-Json -Depth 6 | Set-Content -Encoding utf8 -LiteralPath (Join-Path $work "$Label-run.json")
Write-Output "Started $Label PID $($process.Id); raw evidence: build/issue152/$Label.txt"

$null = $process.Handle
$process.WaitForExit()
$record.exit_code = $process.ExitCode
$record.finished_utc = [DateTime]::UtcNow.ToString("o")
$record | ConvertTo-Json -Depth 6 | Set-Content -Encoding utf8 -LiteralPath (Join-Path $work "$Label-run.json")
if ($record.exit_code -ne 0) { throw "Native run failed: $Label ($($record.exit_code))" }
