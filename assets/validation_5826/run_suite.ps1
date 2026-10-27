param([string]$Runtime='final26c',[string]$Prefix='reading-final')
$ErrorActionPreference='Stop'
$tasks=@(@('limits','limits','enu',''),@('access','access','enu',''),
    @('input','input','enu',''),@('seed','seed','enu',''),
    @('resume','resume','enu','reading-progress.zds'),@('hub','hub','enu',''),
    @('spanish','core','es',''),@('view0','view0','es',''),
    @('view1','view1','es',''),@('view2','view2','es',''))
foreach($task in $tasks){
    $testArgs=@{Runtime=$Runtime;Label=($Prefix+'-'+$task[0]);Script=$task[1];Language=$task[2];Checks=$true}
    if($task[3]){$testArgs.LoadGame=$task[3]}
    & (Join-Path $PSScriptRoot 'run_native.ps1') @testArgs
}
