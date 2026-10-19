param([string]$Directory='issue311-final03',[switch]$Resume)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$cases=@(
    @{Label='player-adapted';Fixture='player.pk3';Script='player.cfg'},
    @{Label='multiple-current';Fixture='multiple.pk3';Script='multi-save.cfg'},
    @{Label='migration';Fixture='migration.pk3';Script='migration.cfg'},
    @{Label='contacts-reload';Fixture='contacts.pk3';Script='contacts_reload.cfg';LoadGame='ca194-original.zds'},
    @{Label='reload-current';Fixture='multiple.pk3';Script='multi-load.cfg';LoadGame='ca311-contact.zds'},
    @{Label='reload-upgraded';Fixture='multiple.pk3';Script='multi-load.cfg';LoadGame='ca311-upgraded.zds'},
    @{Label='separation-save';Fixture='multiple.pk3';Script='separation-save.cfg';LoadGame='ca311-contact.zds'},
    @{Label='separation-reload';Fixture='multiple.pk3';Script='multi-load.cfg';LoadGame='ca311-separated.zds'},
    @{Label='preview-smoke';Fixture='preview.pk3';Script='preview-smoke.cfg';Interactive=$true},
    @{Label='grid-on';Fixture='dense.pk3';Script='grid-512-1.cfg'},
    @{Label='grid-off';Fixture='dense.pk3';Script='grid-512-0.cfg'}
)
foreach($case in $cases){
    $record=Join-Path $root "build/$Directory/$($case.Label)-run.json"
    if($Resume -and (Test-Path -LiteralPath $record)){
        $old=Get-Content -LiteralPath $record -Raw | ConvertFrom-Json
        $log=Join-Path $root "build/$Directory/$($case.Label).txt"
        if($old.exit_code -eq 0 -and (Select-String -LiteralPath $log -Pattern 'CA194 DONE failures=0 passes=\d+' -Quiet) -and !(Select-String -LiteralPath $log -Pattern 'CA194 FAIL' -Quiet)){
            Write-Output "Reusing completed run: $($case.Label)";continue
        }
        throw "Failed or incomplete evidence exists: $($case.Label). Preserve it and choose a fresh label/directory."
    }
    & (Join-Path $PSScriptRoot 'run_native.ps1') -Directory $Directory @case
}
