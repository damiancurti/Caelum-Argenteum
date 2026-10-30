param([ValidateRange(1,900)][int]$Seconds=900,[switch]$Qpc)
$ErrorActionPreference='Stop'
$profileRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$profileOut=Join-Path $profileRoot 'build/issue431/presentation'
$profileTool=Join-Path $profileRoot 'build/issue431/tools/PresentMon-2.6.0-x64.exe'
if ((Get-FileHash -LiteralPath $profileTool -Algorithm SHA256).Hash -ne 'B2A706BC6AD475749E3B7E3409263AA1E6906D45BDCF993F6DBC0F660188F1AF') {
    throw 'PresentMon checksum does not match the official 2.6.0 standalone binary.'
}
New-Item -ItemType Directory -Force -Path $profileOut | Out-Null
$profileTag=Get-Date -Format 'yyyyMMdd-HHmmss'
$profileCsv=Join-Path $profileOut ($profileTag+'.csv')
$profileLog=Join-Path $profileOut ($profileTag+'.log')
$profileMetadata=Join-Path $profileOut ($profileTag+'.json')
$profileStart=[DateTime]::UtcNow.ToString('o')
# The caller obtains Windows consent separately. This script never elevates,
# changes group membership, stops another trace, or installs a service.
# CSV may remain buffered until exit. QPC avoids ambiguous date-mode timezones.
$profileTime=if($Qpc){'--qpc_time_ms'}else{'--date_time'}
& $profileTool --process_name gzdoom.exe --session_name ('Caelum431-'+$profileTag) $profileTime --timed $Seconds --terminate_after_timed --no_console_stats --output_file $profileCsv *> $profileLog
$profileExit=$LASTEXITCODE
@{ started_utc=$profileStart; ended_utc=[DateTime]::UtcNow.ToString('o'); seconds=$Seconds; time_mode=$profileTime;
   exit_code=$profileExit; csv=$profileCsv; tool_sha256='b2a706bc6ad475749e3b7e3409263aa1e6906d45bdcf993f6dbc0f660188f1af';
   source='https://github.com/GameTechDev/PresentMon/releases/tag/v2.6.0' } |
    ConvertTo-Json | Set-Content -LiteralPath $profileMetadata -Encoding UTF8
exit $profileExit
