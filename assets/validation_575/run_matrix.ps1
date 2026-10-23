param([string]$Runtime='current', [string]$Prefix='final')
$ErrorActionPreference='Stop'
foreach ($case in @('contract','trade','craft','storage','regression')) {
    & "$PSScriptRoot/run_native.ps1" -Label "$Prefix-$case" -Runtime $Runtime -Script $case -Checks -Visible
}
