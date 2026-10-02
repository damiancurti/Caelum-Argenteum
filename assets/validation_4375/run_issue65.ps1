param([string]$Label='compile', [string]$Commands='wait 70; quit', [string]$Fixture='', [string]$Runtime='src', [string]$LoadSave='', [string]$Map='MAP01', [switch]$Wait, [switch]$Close)
$ErrorActionPreference='Stop'
$root=(Get-Location).Path
if(!(Test-Path -LiteralPath (Join-Path $root 'build_dev.ps1'))){throw 'Run from the repository root.'}
if($Close){
    if(Test-Path -LiteralPath 'build/issue65_process.txt'){
        $ownedId=[int](Get-Content -LiteralPath 'build/issue65_process.txt')
        $owned=Get-CimInstance Win32_Process -Filter "ProcessId = $ownedId"
        if($owned -and $owned.Name -eq 'gzdoom.exe' -and $owned.CommandLine -match 'build/issue65.ini'){
            Stop-Process -Id $ownedId
            Write-Output "Closed owned issue65 test $ownedId"
        }
    }
    return
}
$config=Get-Content -LiteralPath 'build/gzdoom.ini' -Raw
$config=$config -replace '(?m)^i_pauseinbackground=.*$', 'i_pauseinbackground=false'
$config=$config -replace '(?m)^vid_activeinbackground=.*$', 'vid_activeinbackground=true'
[IO.File]::WriteAllText((Join-Path $root 'build/issue65.ini'),$config)
[IO.File]::WriteAllText((Join-Path $root "build/issue65_$Label.cfg"),$Commands)
$arguments=@('-iwad','"C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD"','-file',$Runtime)
if($Fixture){$arguments+=$Fixture}
$arguments+=@('-config','build/issue65.ini','-savedir','build/issue65_saves','-noautoload','-window','-width','1280','-height','720','+logfile',"build/issue65_$Label.log")
if($LoadSave){
    $savePath=(Resolve-Path -LiteralPath $LoadSave).Path
    if((Split-Path -Parent $savePath) -ne (Join-Path $root 'build/issue65_saves')){throw 'LoadSave must be in the isolated save directory.'}
    $arguments+=@('-loadgame',(Split-Path -Leaf $savePath))
}else{$arguments+=@('+map',$Map)}
$arguments+=@('+exec',"build/issue65_$Label.cfg")
# The author explicitly requested visible live tests.
$probe=Start-Process -FilePath 'C:/Program Files (x86)/GZDoom/gzdoom.exe' -ArgumentList $arguments -WorkingDirectory $root -WindowStyle Normal -PassThru
Write-Output "Issue65 process: $($probe.Id)"
[IO.File]::WriteAllText((Join-Path $root 'build/issue65_process.txt'),[string]$probe.Id)
if($Wait){
    if(!$probe.WaitForExit(60000)){throw "Owned test process $($probe.Id) exceeded 60 seconds; inspect its log/window."}
    Write-Output "Issue65 exit: $($probe.ExitCode)"
}
