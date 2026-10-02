param([string]$Label='before', [string]$Commands='wait 100; quit', [string]$Fixture='build/issue68_qa', [switch]$Clean, [switch]$Package, [string]$BaseMap='', [string]$LoadSave='', [string]$Runtime='', [switch]$Wait)
$ErrorActionPreference='Stop'
$root=(Get-Location).Path
if(!(Test-Path -LiteralPath (Join-Path $root 'build_dev.ps1'))){throw 'Run this evidence launcher from the repository root.'}
if($Commands -match "exec\s+build/issue68_$Label\.cfg"){throw 'A test configuration cannot exec itself.'}
$config=Get-Content -LiteralPath 'build/gzdoom.ini' -Raw
$config=$config -replace '(?m)^i_pauseinbackground=.*$', 'i_pauseinbackground=false'
$config=$config -replace '(?m)^vid_activeinbackground=.*$', 'vid_activeinbackground=true'
[IO.File]::WriteAllText((Join-Path $root 'build/issue68.ini'),$config)
[IO.File]::WriteAllText((Join-Path $root "build/issue68_$Label.cfg"),$Commands)
$source=if($Package){'build/caelum_argenteum_dev.pk3'}else{'src'}
if($Runtime){$source=$Runtime}
$arguments=@('-iwad','"C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD"','-file',$source)
if($BaseMap){$arguments+=$BaseMap}
if($Fixture -and !$Clean){$arguments+=$Fixture}
$arguments+=@('-config','build/issue68.ini','-savedir','build/issue68_saves','-noautoload','-window','-width','1280','-height','720','+logfile',"build/issue68_$Label.log")
if($LoadSave){
    $savePath=(Resolve-Path -LiteralPath $LoadSave).Path
    if((Split-Path -Parent $savePath) -ne (Join-Path $root 'build/issue68_saves')){throw 'LoadSave must be in the isolated evidence save directory.'}
    $arguments+=@('-loadgame',(Split-Path -Leaf $savePath))
}else{$arguments+=@('+map','MAP01')}
$arguments+=@('+exec',"build/issue68_$Label.cfg")
# The author explicitly requested visible live tests.
$probe=Start-Process -FilePath 'C:/Program Files (x86)/GZDoom/gzdoom.exe' -ArgumentList $arguments -WorkingDirectory $root -WindowStyle Normal -PassThru
Write-Output "Issue68 process: $($probe.Id)"
if($Wait){
    if(!$probe.WaitForExit(60000)){throw "Owned test process $($probe.Id) exceeded 60 seconds; inspect its window and log."}
    Write-Output "Issue68 exit: $($probe.ExitCode)"
}
