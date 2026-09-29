param([string]$Label='before', [string]$Commands='wait 100; quit', [string]$Fixture='', [switch]$Baseline, [switch]$Package, [string]$LoadSave='', [switch]$Creator, [switch]$UserGraphics)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
Set-Location -LiteralPath $root
$config=Get-Content -LiteralPath 'build/siege_refine.ini' -Raw
if($UserGraphics){$config=Get-Content -LiteralPath 'build/gzdoom.ini' -Raw}
$config=$config -replace '(?m)^i_pauseinbackground=.*$', 'i_pauseinbackground=false'
$config=$config -replace '(?m)^vid_activeinbackground=.*$', 'vid_activeinbackground=true'
[IO.File]::WriteAllText((Join-Path $root 'build/issue36.ini'),$config)
$Commands | Set-Content -Encoding ascii -LiteralPath "build/issue36_$Label.cfg"
$source=if($Package){'build/caelum_argenteum_dev.pk3'}else{'src'}
$arguments=@('-iwad','"C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD"','-file',$source)
if($Baseline){$arguments+='assets/map01_mansion/MAP01_43624.wad'}
if($Fixture){$arguments+=$Fixture}
$arguments+=@('-config','build/issue36.ini','-savedir','build/issue36_saves','-noautoload','-nosound','-window','+logfile',"build/issue36_$Label.log")
if($UserGraphics){$arguments+=@('-width','1920','-height','1080')}
if($LoadSave){$arguments+=@('-loadgame',$LoadSave)}elseif(!$Creator){$arguments+=@('+map','MAP01')}
$arguments+=@('+exec',"build/issue36_$Label.cfg")
$probe=Start-Process -FilePath 'C:/Program Files (x86)/GZDoom/gzdoom.exe' -ArgumentList $arguments -WorkingDirectory $root -WindowStyle Hidden -PassThru
Write-Output "Issue36 owned process: $($probe.Id)"
if($Creator){
 for($creatorWait=0;$creatorWait -lt 30;$creatorWait++){
  if((Test-Path -LiteralPath "build/issue36_$Label.log") -and (Select-String -LiteralPath "build/issue36_$Label.log" -Pattern 'F36_START confirming native creator' -Quiet)){break}
  Start-Sleep -Seconds 1
 }
 & "$PSScriptRoot/confirm_issue36_creator.ps1" -TargetPid $probe.Id
}
for($probeWait=0;$probeWait -lt 55;$probeWait++){
    if($probe.WaitForExit(1000)){Write-Output "Issue36 exit: $($probe.ExitCode)";break}
    if((Test-Path -LiteralPath "build/issue36_$Label.log") -and (Select-String -LiteralPath "build/issue36_$Label.log" -Pattern 'Script error|Unknown flag|VM execution aborted|Unknown identifier' -Quiet)) {Stop-Process -Id $probe.Id; throw 'Issue36 native compilation failed.'}
}
if(!$probe.HasExited){Stop-Process -Id $probe.Id;Write-Output 'Issue36 timeout; owned process stopped.'}
