param([Parameter(Mandatory=$true)][string]$Directory,[int]$Skip=0,[string]$LabelSuffix='')
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$cases=@('catalogue','save-0','load-0','hub-0','switch-0','save-1','load-1','hub-1','switch-1','save-2','load-2','hub-2','switch-2','boundaries','held-load')
foreach ($case in ($cases | Select-Object -Skip $Skip)) {
    $parameters=@{Directory=$Directory;Label="$case$LabelSuffix";Script="$case.cfg"}
    if ($case.StartsWith('load-')) {
        $parameters.LoadGame="action-$($case.Substring(5)).zds"
    }
    & (Join-Path $PSScriptRoot 'run_native.ps1') @parameters
}
